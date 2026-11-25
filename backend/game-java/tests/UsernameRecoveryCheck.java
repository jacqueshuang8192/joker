import java.util.Map;
import java.util.UUID;
import java.util.concurrent.Callable;
import java.util.concurrent.Executors;

/** 只使用隔离编排内注册的账号，走真实 API 校验密码、一次性恢复码和会话撤销。 */
public class UsernameRecoveryCheck {
    private static Map<?,?> call(String action, Map<String,?> data) throws Exception {
        return (Map<?,?>) HallRoomCheck.post("/playerUser/username/"+action,data,true);
    }
    private static String code(Map<?,?> result) {
        var code=(String)result.get("recoveryCode");
        if (code==null || !code.matches("[0-9A-F]{32}")) throw new AssertionError("missing recovery code");
        return code;
    }
    private static void denied(String action, Map<String,?> data) throws Exception {
        try { call(action,data); } catch (AssertionError rejected) { return; }
        throw new AssertionError("unexpected success: "+action);
    }
    public static void main(String[] args) throws Exception {
        String name="U_"+UUID.randomUUID().toString().substring(0,12).replace("-","_");
        String password=UUID.randomUUID().toString(),next=UUID.randomUUID().toString(),last=UUID.randomUUID().toString();
        var original=Map.of("username",name,"password",password,"requestRecoveryCode",true);
        var recovery=code(call("register",original));
        var session=call("login",original);
        if (session.containsKey("recoveryCode")) throw new AssertionError("login exposed enrolled secret");
        var user=new HallRoomCheck.Client(((Number)session.get("userId")).intValue(),(String)session.get("token"),"",name);
        user.request("/friendTable/current",Map.of("level",324));
        denied("changePassword",Map.of("username",name,"oldPassword",last,"newPassword",next));
        String replacement=code(call("changePassword",Map.of("username",name,"oldPassword",password,"newPassword",next)));
        denied("login",original);
        FriendTableCheck.denied(user,"current",Map.of("level",324));
        denied("resetPassword",Map.of("username",name,"recoveryCode",recovery,"newPassword",last));
        var signed=call("login",Map.of("username",name,"password",next));
        var renewed=new HallRoomCheck.Client(user.uid(),(String)signed.get("token"),"",name);
        renewed.request("/friendTable/current",Map.of("level",324));
        var reset=Map.of("username",name.toUpperCase(java.util.Locale.ROOT),"newPassword",last,
                "recoveryCode",replacement.substring(0,8)+"-"+replacement.substring(8).toLowerCase(java.util.Locale.ROOT));
        try(var workers=Executors.newVirtualThreadPerTaskExecutor()) {
            Callable<Boolean> submit=()->{
                Map<?,?> result;
                try { result=call("resetPassword",reset); } catch(AssertionError refused) { return false; }
                code(result);
                return true;
            };
            var a=workers.submit(submit); var b=workers.submit(submit);
            if (a.get().equals(b.get())) throw new AssertionError("parallel reset must consume code once");
        }
        FriendTableCheck.denied(renewed,"current",Map.of("level",324));
        denied("login",Map.of("username",name,"password",next));
        var finalSession=call("login",Map.of("username",name,"password",last));
        if (!session.get("userId").equals(finalSession.get("userId"))) throw new AssertionError("account changed");
        // 原客户端、升级前的账号都用空恢复凭据，只有新版客户端验证原密码后才能领取。
        var old=Map.of("username",name+"x","password",password);
        call("register",old); call("login",old);
        denied("resetPassword",Map.of("username",name+"x","recoveryCode",replacement,"newPassword",last));
        var optIn=Map.of("username",name+"x","password",password,"requestRecoveryCode",true);
        code(call("login",optIn));
        if(call("login",optIn).containsKey("recoveryCode")) throw new AssertionError("legacy enrollment repeated");
        System.out.println("Verified password change, concurrent single-use reset, code rotation, old sessions and legacy enrollment.");
    }
}
