package mars.mips.instructions.syscalls;

import mars.ProcessingException;
import mars.ProgramStatement;
import mars.ext.game.GameScreen;
import mars.mips.hardware.RegisterFile;
import mars.util.SystemIO;

public class SyscallGameUpdateBombInfo extends AbstractSyscall
{

    public SyscallGameUpdateBombInfo()
    {
        super(123, "Update Bomb Info");
        // TODO Auto-generated constructor stub
    }

    @Override
    public void simulate(ProgramStatement statement) throws ProcessingException
    {
        int sbNum = RegisterFile.getValue(4);
        int rbNum = RegisterFile.getValue(5);
        GameScreen game = GameScreen.getInstance();
        if (game == null)
        {
            SystemIO.printString("GameScreen has not been created!");
            throw new ProcessingException();
        }
        if (sbNum >= 0)
        {
            game.updateSimpleBombInfo(sbNum);
        }
        if (rbNum >= 0)
        {
            game.updateRemoteBombInfo(rbNum);
        }
    }

}
