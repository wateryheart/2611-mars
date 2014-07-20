package mars.mips.instructions.syscalls;

import mars.ProcessingException;
import mars.ProgramStatement;
import mars.ext.game.GameScreen;
import mars.util.SystemIO;

public class SyscallGameFreshScreen extends AbstractSyscall
{

    public SyscallGameFreshScreen()
    {
        super(119, "Fresh Screen");
        // TODO Auto-generated constructor stub
    }

    @Override
    public void simulate(ProgramStatement statement) throws ProcessingException
    {
        GameScreen game = GameScreen.getInstance();
        if (game == null)
        {
            SystemIO.printString("In Creating Ship, but GameScreen has not been created first!");
            throw new ProcessingException();
        }
        game.refreshScreen();
        //System.out.println("Called FreshScreen()!");
    }

}
