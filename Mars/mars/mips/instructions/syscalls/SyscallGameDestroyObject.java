package mars.mips.instructions.syscalls;

import mars.ProcessingException;
import mars.ProgramStatement;
import mars.ext.game.GameObject;
import mars.ext.game.GameScreen;
import mars.mips.hardware.RegisterFile;
import mars.util.SystemIO;

public class SyscallGameDestroyObject extends AbstractSyscall
{

    public SyscallGameDestroyObject()
    {
        super(116, "Destroy Object");
        // TODO Auto-generated constructor stub
    }

    @Override
    public void simulate(ProgramStatement statement) throws ProcessingException
    {
        int id = RegisterFile.getValue(4);
        GameScreen game = GameScreen.getInstance();
        if (game == null)
        {
            SystemIO.printString("GameScreen has not been created!");
            throw new ProcessingException();
        }
        game.destroyGameObject(id);
        //System.out.println("Destroy object: " + id);
    }

}