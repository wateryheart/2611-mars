package mars.mips.instructions.syscalls;

import mars.ProcessingException;
import mars.ProgramStatement;
import mars.ext.game.GameConfigFile;
import mars.ext.game.GameRemoteBombObject;
import mars.ext.game.GameScreen;
import mars.mips.hardware.RegisterFile;
import mars.util.SystemIO;

public class SyscallCreateRemoteBomb extends AbstractSyscall
{

    public SyscallCreateRemoteBomb()
    {
        super(107, "Create Remote Bomb");
    }

    @Override
    public void simulate(ProgramStatement statement) throws ProcessingException
    {
        int id = RegisterFile.getValue(4);
        int x_loc = RegisterFile.getValue(5);
        int y_loc = RegisterFile.getValue(6);
        int speed = RegisterFile.getValue(7);
        GameRemoteBombObject obj = new GameRemoteBombObject(id, x_loc, y_loc,
                GameConfigFile.REMOTE_BOMB_ACTIVE,
                GameConfigFile.REMOTE_BOMB_INACTIVE,
                GameConfigFile.REMOTE_BOMB_EXPLODE);
        obj.setSpeed(speed);
        GameScreen game = GameScreen.getInstance();
        if (game == null)
        {
            SystemIO.printString("In Creating Remote Bomb, but GameScreen has not been created first!");
            throw new ProcessingException();
        }
        game.addGameObject(id, obj);
        /*System.out.println("Create a remote bomb, id: " + id + "(" + x_loc
                + ", " + y_loc + ")");*/
    }

}
