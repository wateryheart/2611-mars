package mars.ext.game;

import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.Image;
import java.awt.Toolkit;
import java.io.File;
import java.io.IOException;
import java.net.URL;

import javax.imageio.ImageIO;

/**
 * Ship Object
 * 
 * @author jasonwangm
 * 
 */
public class GameShipObject extends GameObject implements ActiveElementInterface
{
    public static final int HIT_POINT = 1;
    private Image leftImage = null;
    private Image rightImage = null;
    private boolean isRight = true; // indicating current direction
    private int speed;
    private int hitPoint;

    public GameShipObject(int id, int x, int y, String leftImgFileName,
            String rightImgFileName)
    {
        super(id, x, y);
        speed = 0;
        hitPoint = HIT_POINT;
        URL im = this.getClass().getResource(leftImgFileName);
        if (im == null)
        {
        	System.err.println("Internal Error: images folder or file not found");
            System.exit(0);
        }
		leftImage = Toolkit.getDefaultToolkit().getImage(im);
		im = this.getClass().getResource(rightImgFileName);
        if (im == null)
        {
        	System.err.println("Internal Error: images folder or file not found");
            System.exit(0);
        }
		rightImage = Toolkit.getDefaultToolkit().getImage(im);
    }

    public GameShipObject(int id, String leftImgFileName,
            String rightImgFileName)
    {
        this(id, 0, 0, leftImgFileName, rightImgFileName);
    }

    @Override
    public void paint(Graphics graph)
    {
        Graphics2D g2 = (Graphics2D) graph;
        if (isRight)
        {
            g2.drawImage(rightImage, xLoc, yLoc, null);
        }
        else
        {
            g2.drawImage(leftImage, xLoc, yLoc, null);
        }
    }

    @Override
    public int getScore()
    {
        return 0;
    }

    @Override
    public void deductHitPoint(int p)
    {
        
    }
    
    public int getHitPoint()
    {
        return this.hitPoint;
    }

    @Override
    public void setDirection(boolean right)
    {
        this.isRight = right;
    }

    @Override
    public boolean getDirection()
    {
        return this.isRight;
    }

    @Override
    public void setSpeed(int v)
    {
        this.speed = v;
    }

    @Override
    public int getSpeed()
    {
        return this.speed;
    }

    @Override
    public void updateLocation()
    {
        if (this.isRight)
        {
            xLoc += speed;
        }
        else
        {
            xLoc -= speed;
        }
    }

}
