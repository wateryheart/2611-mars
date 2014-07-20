package mars.mips.instructions.syscalls;

import mars.ProcessingException;
import mars.ProgramStatement;
import mars.ext.game.GameScreen;
import mars.mips.hardware.RegisterFile;

import mars.util.SystemIO;

public class SyscallGamePlaySound extends AbstractSyscall
{

    public SyscallGamePlaySound()
    {
        super(105, "Play Sound");
        // TODO Auto-generated constructor stub
    }

    @Override
    public void simulate(ProgramStatement statement) throws ProcessingException
    {
        int soundId = RegisterFile.getValue(4);
        boolean toLoop = RegisterFile.getValue(5) == 1 ? true : false;
        GameScreen game = GameScreen.getInstance();
        if (game == null)
        {
            SystemIO.printString("GameScreen has not been created!");
            throw new ProcessingException();
        }
        game.playSound(soundId, toLoop);
        /*if (soundId == 1 || soundId == 5)
        {
            System.out.print("Bomb...........");
        }*/
    }
}
