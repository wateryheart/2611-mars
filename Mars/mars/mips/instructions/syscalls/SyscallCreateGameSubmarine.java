package mars.mips.instructions.syscalls;

import mars.ProcessingException;
import mars.ProgramStatement;
import mars.ext.game.GameConfigFile;
import mars.ext.game.GameScreen;
import mars.ext.game.GameSubmarineObject;
import mars.mips.hardware.RegisterFile;
import mars.util.SystemIO;

public class SyscallCreateGameSubmarine extends AbstractSyscall
{

    public SyscallCreateGameSubmarine()
    {
        super(102, "Create Submarine");
    }

    @Override
    public void simulate(ProgramStatement statement) throws ProcessingException
    {
        int id = RegisterFile.getValue(4);
        int x_loc = RegisterFile.getValue(5);
        int y_loc = RegisterFile.getValue(6);
        int speed = RegisterFile.getValue(7);
        GameSubmarineObject obj = new GameSubmarineObject(id, x_loc, y_loc,
                GameConfigFile.SUBMARINE_LEFT, GameConfigFile.SUBMARINE_RIGHT,
                GameConfigFile.SUBMARINE_DAMAGE_L,
                GameConfigFile.SUBMARINE_DAMAGE_R,
                GameConfigFile.SUBMARINE_DESTROYED);
        obj.setSpeed(speed);
        GameScreen game = GameScreen.getInstance();
        if (game == null)
        {
            SystemIO.printString("In Creating Submarine, but GameScreen has not been created first!");
            throw new ProcessingException();
        }
        game.addGameObject(id, obj);

    }

}
