<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Title</title>
    <script src="../js/jquery-2.1.4.min.js" type="text/javascript"></script>
    <script src="../js/qrcode.js" type="text/javascript"></script>
</head>
<body>
<div>
    请保存此二维码并用微信识别此二维码进行支付
    <div id="qrcode"></div>
    <form id="Form1" name="Form1" method="post" action="${url}">
        <%--<input type="parter" name="parter" value="${parter}" />--%>
        <%--<input type="type" name="type" value="${type}" />--%>
        <%--<input type="value" name="value" value="${value}" />--%>
        <%--<input type="orderid" name="orderid" value="${orderid}" />--%>
        <%--<input type="callbackurl" name="callbackurl" value="${callbackurl}" />--%>
        <%--<input type="refbackurl" name="refbackurl" value="${refbackurl}" />--%>
        <%--<input type="payerIp " name="payerIp" value="${payerIp }" />--%>
        <%--<input type="attach" name="attach" value="${attach}" />--%>
        <%--<input type="sign" name="sign" value="${sign}" />--%>
        <%--<input type="submit" name="sub" id="sub" value="sub"/>--%>

        <%--<input name="p1_yingyongnum"  value="${p1_yingyongnum}" type="hidden" />--%>
        <%--<input name="p2_ordernumber"  value="${p2_ordernumber}" type="hidden" />--%>
        <%--<input name="p3_money" value="${p3_money}" type="hidden" />--%>
        <%--<input name="p6_ordertime"  value="${p6_ordertime}" type="hidden" />--%>
        <%--<input name="p7_productcode"  value="${p7_productcode}" type="hidden" />--%>
        <%--<input name="p8_sign"  value="${p8_sign}" type="hidden" />--%>
        <%--<input name="p14_customname" value="${p14_customname}"  type="hidden"/>--%>
        <%--<input name="p16_customip"  value="${p16_customip}" type="hidden" />--%>
        <%--<input name="p25_terminal" value="${p25_terminal}" type="hidden" />--%>
        <%--<input name="p26_ext1" value="${p26_ext1}" type="hidden" />--%>
            <%--<input type="submit" name="sub" id="sub" value="sub"/>--%>

            <input name="p1_yingyongnum"  value="${p1_yingyongnum}" />
            <input name="p2_ordernumber"  value="${p2_ordernumber}"/>
            <input name="p3_money" value="${p3_money}" />
            <input name="p6_ordertime"  value="${p6_ordertime}" />
            <input name="p7_productcode"  value="${p7_productcode}"/>
            <input name="p8_sign"  value="${p8_sign}"/>
            <input name="p14_customname" value="${p14_customname}"/>
            <input name="p16_customip"  value="${p16_customip}" />
            <input name="paytype" value="zz"/>

            <input type="submit" name="sub" id="sub" value="sub"/>

    </form>
</div>
<script>
    $(document).ready(function () {
        $("#sub").click();
    })
</script>
</body>

</html>
