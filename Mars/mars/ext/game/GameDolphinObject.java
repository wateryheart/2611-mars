package mars.ext.game;

import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.Image;
import java.awt.Toolkit;
import java.io.File;
import java.io.IOException;
import java.net.URL;

import javax.imageio.ImageIO;

public class GameDolphinObject extends GameObject implements
        ActiveElementInterface
{
    public static final int HIT_POINT = 10;
    private Image leftImage = null;
    private Image rightImage = null;
    private Image destroyImage = null;
    private boolean isRight = true;
    private boolean isDestroyed = false;
    private int hitPoint;
    private int speed;

    public GameDolphinObject(int id, int x, int y, String leftImgName,
            String rightImgName, String destroyImgName)
    {
        super(id, x, y);
        hitPoint = HIT_POINT;
        speed = 0;
        URL im = this.getClass().getResource(leftImgName);
        if (im == null)
        {
        	System.err.println("Internal Error: images folder or file not found");
            System.exit(0);
        }
		leftImage = Toolkit.getDefaultToolkit().getImage(im);
		im = this.getClass().getResource(rightImgName);
        if (im == null)
        {
        	System.err.println("Internal Error: images folder or file not found");
            System.exit(0);
        }
		rightImage = Toolkit.getDefaultToolkit().getImage(im);
		im = this.getClass().getResource(destroyImgName);
        if (im == null)
        {
        	System.err.println("Internal Error: images folder or file not found");
            System.exit(0);
        }
		destroyImage = Toolkit.getDefaultToolkit().getImage(im);
    }

    public GameDolphinObject(int id, String leftImgName, String rightImgName,
            String destroyImgName)
    {
        this(id, 0, 0, leftImgName, rightImgName, destroyImgName);
    }

    @Override
    public void paint(Graphics graph)
    {
        Graphics2D g2 = (Graphics2D) graph;
        if (isDestroyed)
        {
            g2.drawImage(destroyImage, xLoc, yLoc, null);
        }
        else if (isRight)
        {
            g2.drawImage(rightImage, xLoc, yLoc, null);
        }
        else
        {
            g2.drawImage(leftImage, xLoc, yLoc, null);
        }
    }

    public int getScore()
    {
        return HIT_POINT - hitPoint;
    }

    @Override
    public void deductHitPoint(int p)
    {
        hitPoint = hitPoint - p;
        if (hitPoint <= 0)
        {
            hitPoint = 0;
            this.isDestroyed = true;
        }
    }

    public int getHitPoint()
    {
        return this.hitPoint;
    }

    public void setDirection(boolean right)
    {
        this.isRight = right;
    }

    public boolean getDirection()
    {
        return this.isRight;
    }

    public void setSpeed(int v)
    {
        this.speed = v;
    }

    public int getSpeed()
    {
        return this.speed;
    }

    public void updateLocation()
    {
        if (this.isDestroyed)
        {
            return;
        }
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