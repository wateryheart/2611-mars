package mars.mips.instructions.syscalls;

import mars.ProcessingException;
import mars.ProgramStatement;
import mars.ext.game.GameObject;
import mars.ext.game.GameRemoteBombObject;
import mars.ext.game.GameScreen;
import mars.mips.hardware.RegisterFile;
import mars.util.SystemIO;

public class SyscallGameActivateRemoteBomb extends AbstractSyscall
{

    public SyscallGameActivateRemoteBomb()
    {
        super(109, "Activate Remote Bomb");
        // TODO Auto-generated constructor stub
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
        if (obj instanceof GameRemoteBombObject)
        {
            GameRemoteBombObject obj2 = (GameRemoteBombObject) obj;
            obj2.setActive(true);
            //System.out.println("Activate Remote Bomb: " + id);
        }
    }

}
