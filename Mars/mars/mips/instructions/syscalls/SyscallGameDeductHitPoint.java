package mars.mips.instructions.syscalls;

import mars.ProcessingException;
import mars.ProgramStatement;
import mars.ext.game.ActiveElementInterface;
import mars.ext.game.GameObject;
import mars.ext.game.GameScreen;
import mars.mips.hardware.RegisterFile;
import mars.util.SystemIO;

public class SyscallGameDeductHitPoint extends AbstractSyscall
{

    public SyscallGameDeductHitPoint()
    {
        super(114, "Deduct Hit Point");
    }

    @Override
    public void simulate(ProgramStatement statement) throws ProcessingException
    {
        int id = RegisterFile.getValue(4);
        int point = RegisterFile.getValue(5);
        GameScreen game = GameScreen.getInstance();
        int direction = -1;
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
        ActiveElementInterface ele = (ActiveElementInterface) obj;
        ele.deductHitPoint(point);
    }

}
