package mars.mips.instructions.syscalls;

import mars.ProcessingException;
import mars.ProgramStatement;
import mars.ext.game.GameConfigFile;
import mars.ext.game.GameDolphinObject;
import mars.ext.game.GameScreen;
import mars.mips.hardware.RegisterFile;
import mars.util.SystemIO;

public class SyscallCreateGameDolphin extends AbstractSyscall
{

    public SyscallCreateGameDolphin()
    {
        super(103, "Create Dolphin");
    }

    @Override
    public void simulate(ProgramStatement statement) throws ProcessingException
    {
        int id = RegisterFile.getValue(4);
        int x_loc = RegisterFile.getValue(5);
        int y_loc = RegisterFile.getValue(6);
        int speed = RegisterFile.getValue(7);
        GameDolphinObject obj = new GameDolphinObject(id, x_loc, y_loc,
                GameConfigFile.DOLPHIN_LEFT, GameConfigFile.DOLPHIN_RIGHT,
                GameConfigFile.DOLPHIN_DESTROYED);
        obj.setSpeed(speed);
        GameScreen game = GameScreen.getInstance();
        if (game == null)
        {
            SystemIO.printString("In Creating Dolphin, but GameScreen has not been created first!");
            throw new ProcessingException();
        }
        game.addGameObject(id, obj);
        /*System.out.println("Create an dolphine: " + id + "(" + x_loc + ","
                + y_loc + ")");*/
    }
}
