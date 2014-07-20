package mars.mips.instructions.syscalls;

import mars.ProcessingException;
import mars.ProgramStatement;
import mars.ext.game.GameObject;
import mars.ext.game.GameScreen;
import mars.mips.hardware.RegisterFile;
import mars.util.SystemIO;

public class SyscallGameUpdateScore extends AbstractSyscall
{

    public SyscallGameUpdateScore()
    {
        super(117, "Update Game Score");
        // TODO Auto-generated constructor stub
    }

    @Override
    public void simulate(ProgramStatement statement) throws ProcessingException
    {
        int score = RegisterFile.getValue(4);
        GameScreen game = GameScreen.getInstance();
        if (game == null)
        {
            SystemIO.printString("GameScreen has not been created!");
            throw new ProcessingException();
        }
        game.updateScore(score);
        //System.out.println("Update Score: " + score);
    }

}
