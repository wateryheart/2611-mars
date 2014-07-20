package mars.mips.instructions.syscalls;

import mars.ProcessingException;
import mars.ProgramStatement;
import mars.ext.game.GameScreen;
import mars.mips.hardware.RegisterFile;
import mars.util.SystemIO;

public class SyscallGameStopSound extends AbstractSyscall
{

    public SyscallGameStopSound()
    {
        super(122, "Stop Sound");
    }

    @Override
    public void simulate(ProgramStatement statement) throws ProcessingException
    {
        int soundId = RegisterFile.getValue(4);
        GameScreen game = GameScreen.getInstance();
        if (game == null)
        {
            SystemIO.printString("GameScreen has not been created!");
            throw new ProcessingException();
        }
        game.stopSound(soundId);
    }

}
