package mars.mips.instructions.syscalls;

import mars.ProcessingException;
import mars.ProgramStatement;
import mars.ext.game.GameObject;
import mars.ext.game.GameRemoteBombObject;
import mars.ext.game.GameScreen;
import mars.mips.hardware.RegisterFile;
import mars.util.SystemIO;

public class SyscallGameGetRemoteBombStatus extends AbstractSyscall
{

    public SyscallGameGetRemoteBombStatus()
    {
        super(108, "Game Remote Bomb Status");
    }

    @Override
    public void simulate(ProgramStatement statement) throws ProcessingException
    {
        int id = RegisterFile.getValue(4);
        GameScreen game = GameScreen.getInstance();
        int result = -1;
        if (game == null)
        {
            SystemIO.printString("GameScreen has not been created!");
            throw new ProcessingException();
        }
        GameObject obj = game.getGameObject(id);
        if (obj == null)
        {
            SystemIO.printString("RemoteBombObject: id=" + id
                    + " does not exist!");
            throw new ProcessingException();
        }
        GameRemoteBombObject obj2 = (GameRemoteBombObject) game
                .getGameObject(id);
        if (obj2.isActive())
        {
            result = 1;
        }
        else
        {
            result = 0;
        }
        RegisterFile.updateRegister(2, result);
    }
}
