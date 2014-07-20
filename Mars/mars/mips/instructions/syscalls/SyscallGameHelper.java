package mars.mips.instructions.syscalls;

import mars.Globals;
import mars.mips.hardware.AddressErrorException;
import mars.mips.hardware.Memory;

/**
 * Provide some common functionalities for other syscalls for the Game!
 * 
 * @author jasonwangm
 * 
 */
public final class SyscallGameHelper
{
    public static String getStringFromMIPS(int baseAddress)
    {
        StringBuffer buffer = new StringBuffer();
        try
        {
            Memory mem = Globals.memory;
            char ch = '\0';
            ch = (char) (mem.getByte(baseAddress) & 0xFF);
            baseAddress++;
            while (ch != '\0')
            {
                buffer.append(ch);
                ch = (char) (mem.getByte(baseAddress) & 0xFF);
                baseAddress++;
            }
        }
        catch (AddressErrorException e)
        {
            System.err.println("Invalid byte address for the string!");
            e.printStackTrace();
        }
        return buffer.toString();
    }

    private SyscallGameHelper()
    {
        // TODO Auto-generated constructor stub
    }

}
