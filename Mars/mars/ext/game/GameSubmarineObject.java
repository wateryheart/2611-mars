package mars.ext.game;

import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.Image;
import java.awt.Toolkit;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.net.URL;

import javax.imageio.ImageIO;

public class GameSubmarineObject extends GameObject implements
        ActiveElementInterface
{
    public static final int HIT_POINT = 20;
    private Image leftImage;
    private Image rightImage;
    private Image leftDamageImage;
    private Image rightDamageImage;
    private Image destroyImage;
    private boolean isRight = true;
    private boolean isDamage = false;
    private boolean isDestroy = false;
    private int hitPoint;
    private int speed;

    public GameSubmarineObject(int id, int x, int y, String leftImgName,
            String rightImgName, String leftDesName, String rightDesName,
            String desName)
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
		im = this.getClass().getResource(leftDesName);
        if (im == null)
        {
        	System.err.println("Internal Error: images folder or file not found");
            System.exit(0);
        }
		leftDamageImage = Toolkit.getDefaultToolkit().getImage(im);
		im = this.getClass().getResource(rightDesName);
        if (im == null)
        {
        	System.err.println("Internal Error: images folder or file not found");
            System.exit(0);
        }
		rightDamageImage = Toolkit.getDefaultToolkit().getImage(im);
		im = this.getClass().getResource(desName);
        if (im == null)
        {
        	System.err.println("Internal Error: images folder or file not found");
            System.exit(0);
        }
		destroyImage = Toolkit.getDefaultToolkit().getImage(im);
    }

    public GameSubmarineObject(int id, String leftImgName, String rightImgName,
            String leftDesName, String rightDesName, String desName)
    {
        this(id, 0, 0, leftImgName, rightImgName, leftDesName, rightDesName,
                desName);
    }

    @Override
    public void paint(Graphics graph)
    {
        Graphics2D g2 = (Graphics2D) graph;
        if (isDestroy)
        {
            g2.drawImage(destroyImage, xLoc, yLoc, null);
        }
        else if (isDamage)
        {
            if (isRight)
            {
                g2.drawImage(rightDamageImage, xLoc, yLoc, null);
            }
            else
            {
                g2.drawImage(leftDamageImage, xLoc, yLoc, null);
            }
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

    @Override
    public int getScore()
    {
        return HIT_POINT - this.hitPoint;
    }

    @Override
    public void deductHitPoint(int p)
    {
        this.hitPoint -= p;
        if (this.hitPoint < HIT_POINT)
        {
            this.isDamage = true;
        }
        if (this.hitPoint <= 0)
        {
            this.isDestroy = true;
            this.hitPoint = 0;
        }
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
        if (this.isDestroy)
        {
            return;
        }
        if (this.isRight)
        {
            if (this.isDamage)
            {
                xLoc += speed / 2;
            }
            else
            {
                xLoc += speed;
            }
        }
        else
        {
            if (this.isDamage)
            {
                xLoc -= speed / 2;
            }
            else
            {
                xLoc -= speed;
            }
        }
    }
}
