package mars.mips.instructions.syscalls;

import mars.ProcessingException;
import mars.ProgramStatement;
import mars.ext.game.GameConfigFile;
import mars.ext.game.GameScreen;
import mars.ext.game.GameShipObject;
import mars.mips.hardware.RegisterFile;
import mars.util.SystemIO;

public class SyscallCreateGameShip extends AbstractSyscall
{

    public SyscallCreateGameShip()
    {
        super(101, "Create Ship");
    }

    @Override
    public void simulate(ProgramStatement statement) throws ProcessingException
    {
        // $a0: id
        // $a1: x_loc
        // $a2: y_loc
        // $a3: speed
        int id = RegisterFile.getValue(4);
        int x_loc = RegisterFile.getValue(5);
        int y_loc = RegisterFile.getValue(6);
        int speed = RegisterFile.getValue(7);
        //System.out.println("Ship: x_loc="+x_loc);
        //System.out.println("Ship: y_loc="+y_loc);
        GameShipObject obj = new GameShipObject(id, x_loc, y_loc,
                GameConfigFile.SHIP_LEFT, GameConfigFile.SHIP_RIGHT);
        obj.setSpeed(speed);
        GameScreen game = GameScreen.getInstance();
        if (game == null)
        {
            SystemIO.printString("In Creating Ship, but GameScreen has not been created first!");
            throw new ProcessingException();
        }
        game.addGameObject(id, obj);
    }

}
