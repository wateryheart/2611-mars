package mars.mips.instructions.syscalls;

import mars.ProcessingException;
import mars.ProgramStatement;
import mars.ext.game.GameScreen;
import mars.mips.hardware.RegisterFile;
import mars.util.SystemIO;

public class SyscallCreateGame extends AbstractSyscall
{
    public SyscallCreateGame()
    {
        super(100, "Create Game");
    }

    @Override
    public void simulate(ProgramStatement statement) throws ProcessingException
    {
        // $a0: base address of the string of the game's title
        // $a1: width
        // $a2: height
        String title = SyscallGameHelper.getStringFromMIPS(RegisterFile.getValue(4));
        int width = RegisterFile.getValue(5);
        int height = RegisterFile.getValue(6);
        GameScreen.createIntance(title, width, height);
    }

}
