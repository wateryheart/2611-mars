package mars.mips.instructions.syscalls;

import mars.ProcessingException;
import mars.ProgramStatement;
import mars.ext.game.GameConfigFile;
import mars.ext.game.GameScreen;
import mars.ext.game.GameShipObject;
import mars.ext.game.GameTextObject;
import mars.mips.hardware.RegisterFile;
import mars.util.SystemIO;

public class SyscallCreateGameText extends AbstractSyscall
{

    public SyscallCreateGameText()
    {
        super(104, "Create Text");
        // TODO Auto-generated constructor stub
    }

    @Override
    public void simulate(ProgramStatement statement) throws ProcessingException
    {
        int id = RegisterFile.getValue(4);
        int x_loc = RegisterFile.getValue(5);
        int y_loc = RegisterFile.getValue(6);
        String text = SyscallGameHelper.getStringFromMIPS(RegisterFile.getValue(7));
        GameTextObject obj = new GameTextObject(id, x_loc, y_loc);
        obj.setText(text);
        GameScreen game = GameScreen.getInstance();
        if (game == null)
        {
            SystemIO.printString("In Creating Ship, but GameScreen has not been created first!");
            throw new ProcessingException();
        }
        game.addGameObject(id, obj);
        //System.out.println(text);
    }

}
