package mars.mips.instructions.syscalls;

import mars.ProcessingException;
import mars.ProgramStatement;
import mars.ext.game.GameObject;
import mars.ext.game.GameRemoteBombObject;
import mars.ext.game.GameScreen;
import mars.mips.hardware.RegisterFile;
import mars.util.SystemIO;

public class SyscallGameGetObjLocation extends AbstractSyscall
{

    public SyscallGameGetObjLocation()
    {
        super(110, "Get Object Location");
        // TODO Auto-generated constructor stub
    }

    @Override
    public void simulate(ProgramStatement statement) throws ProcessingException
    {
        int id = RegisterFile.getValue(4);
        GameScreen game = GameScreen.getInstance();
        int x_loc = -1;
        int y_loc = -1;
        if (game == null)
        {
            SystemIO.printString("GameScreen has not been created!");
            throw new ProcessingException();
        }
        GameObject obj = game.getGameObject(id);
        if (obj == null)
        {
            SystemIO.printString("GameObject: id=" + id
                    + " does not exist!");
            throw new ProcessingException();
        }
        x_loc = obj.getXLoc();
        y_loc = obj.getYLoc();
        RegisterFile.updateRegister(2, x_loc);
        RegisterFile.updateRegister(3, y_loc);
    }

}
