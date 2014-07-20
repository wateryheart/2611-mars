package mars.ext.game;

import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.Image;
import java.awt.Toolkit;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.net.URL;

import javax.imageio.ImageIO;

import mars.Globals;

public class GameImage extends GameObject
{
    private Image image;

    public GameImage(int id, int x, int y, String imgName)
    {
        super(id, x, y);
        //image = ImageIO.read(new File(imgName));
        URL im = this.getClass().getResource(imgName);
        if (im == null)
        {
        	System.err.println("Internal Error: images folder or file not found");
            System.exit(0);
        }
		image = Toolkit.getDefaultToolkit().getImage(im);
    }

    public GameImage(int id, String imgName)
    {
        this(id, 0, 0, imgName);
    }

    @Override
    public void paint(Graphics graph)
    {
        Graphics2D g2 = (Graphics2D) graph;
        g2.drawImage(image, xLoc, yLoc, null);
    }

}
