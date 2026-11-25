import com.j.joker.game.runfast.domain.RunFastScore;
import com.j.joker.game.runfast.domain.RunFastScore.Seat;
import java.util.List;
import java.util.Map;

public class RunFastCheck {
    public static void main(String[] args) {
        var seats = List.of(new Seat(1,0,0),new Seat(2,1,1),new Seat(3,16,0));
        if (!RunFastScore.settle(seats, 100).equals(Map.of(1,2200L,2,2000L,3,-4200L)))
            throw new AssertionError("报单、关门与未赢玩家的炸弹计分不符");
        try {
            RunFastScore.settle(List.of(new Seat(1,0,0),new Seat(2,0,1),new Seat(3,2,0)),1);
            throw new AssertionError("多人同时出完");
        } catch (IllegalArgumentException expected) { }
    }
}
