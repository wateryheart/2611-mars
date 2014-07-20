package mars.mips.instructions.syscalls;

import mars.ProcessingException;
import mars.ProgramStatement;
import mars.ext.game.GameBombObject;
import mars.ext.game.GameConfigFile;
import mars.ext.game.GameScreen;
import mars.mips.hardware.RegisterFile;
import mars.util.SystemIO;

public class SyscallCreateSimpleBomb extends AbstractSyscall
{

    public SyscallCreateSimpleBomb()
    {
        super(106, "Create Simple Bomb");
    }

    @Override
    public void simulate(ProgramStatement statement) throws ProcessingException
    {
        int id = RegisterFile.getValue(4);
        int x_loc = RegisterFile.getValue(5);
        int y_loc = RegisterFile.getValue(6);
        int speed = RegisterFile.getValue(7);
        GameBombObject obj = new GameBombObject(id, x_loc, y_loc,
                GameConfigFile.SIMPLE_BOMB, GameConfigFile.SIMPLE_BOMB_EXPLODE);
        obj.setSpeed(speed);
        GameScreen game = GameScreen.getInstance();
        if (game == null)
        {
            SystemIO.printString("In Creating Simple Bomb, but GameScreen has not been created first!");
            throw new ProcessingException();
        }
        game.addGameObject(id, obj);
        /*System.out.println("Create a simple bomb, id:" + id + " (" + x_loc
                + ", " + y_loc + ")");*/
    }

}
