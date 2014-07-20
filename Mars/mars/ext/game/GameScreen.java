package mars.ext.game;

import java.awt.*;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;
import java.io.File;
import java.io.IOException;
import java.util.*;

import javax.imageio.ImageIO;
import javax.swing.*;

/**
 * This class is the GUI component of the game.
 * 
 * @author jasonwangm
 * 
 */
public class GameScreen extends JFrame
{
    private int width; // the width of the screen
    private int height; // the height of the screen
    private String title; // the title of the screen
    private int score; // the score of the game
    private int simpleBombLeft; // the number of simple bombs left
    private int remoteBombLeft; // the number of remote bombs left
    private Font font = new Font("Serif", Font.BOLD, 24);
    // the vector of game objects
    private Hashtable<Integer, GameObject> gameObjs;
    private SoundPlayer soundPlayer;
    private MMIOInput keyListener; // the memeory mapped IO
    private GameImage bgImage;
    private ScreenPanel panel;

    private static GameScreen instance;

    public static GameScreen getInstance()
    {
        return instance;
    }

    public static synchronized GameScreen createIntance(String title,
            int width, int height)
    {
        if (instance == null)
        {
            instance = new GameScreen(title, width, height);
        }
        return instance;
    }

    private class ScreenPanel extends JPanel
    {
        public ScreenPanel()
        {
        }

        public void paintComponent(Graphics g)
        {
            Graphics2D g2 = (Graphics2D) g;
            if (bgImage != null)
            {
                bgImage.paint(g);
            }
            for (Map.Entry<Integer, GameObject> entry : gameObjs.entrySet())
            {
                GameObject obj = entry.getValue();
                obj.paint(g);
            }
            g2.setFont(font);
            g2.setColor(Color.red);
            g2.drawString("Score: " + Integer.toString(score), 66, 40);
            g2.drawString(Integer.toString(simpleBombLeft), 480, 40);
            g2.drawString(Integer.toString(remoteBombLeft), 650, 40);
        }
    }

    private GameScreen(String title, int width, int height)
    {
        this.title = title;
        this.width = width;
        this.height = height;
        this.score = 0;
        this.simpleBombLeft = 0;
        this.remoteBombLeft = 0;
        this.bgImage = new GameImage(-1, GameConfigFile.BACKGROUND);
        this.gameObjs = new Hashtable<Integer, GameObject>();
        this.soundPlayer = new SoundPlayer();
        this.setTitle(title);
        this.setDefaultCloseOperation(JFrame.DISPOSE_ON_CLOSE);
        this.setSize(width, height);
        this.setResizable(false);
        this.addWindowListener(new WindowAdapter()
        {
            public void windowClosed(WindowEvent e)
            {
                keyListener.destroy();
                soundPlayer.stopAll();
                bgImage = null;
                gameObjs.clear();
                instance = null;
            }
        });
        this.panel = new ScreenPanel();
        this.getContentPane().add(panel);
        this.keyListener = new MMIOInput(true);
        this.addKeyListener(keyListener);
        this.setVisible(true);
    }
    
    public void playSound(int soundId, boolean toLoop)
    {
        this.soundPlayer.play(soundId, toLoop);
    }
    
    public void stopSound(int soundId)
    {
        this.soundPlayer.stopSound(soundId);
    }
    
    public void addGameObject(int id, GameObject obj)
    {
        this.gameObjs.put(id, obj);
    }

    public GameObject getGameObject(int id)
    {
        if (!gameObjs.containsKey(id))
        {
            return null;
        }
        return gameObjs.get(id);
    }

    public void updateSimpleBombInfo(int sbLeft)
    {
        this.simpleBombLeft = sbLeft;
    }
    
    public void updateRemoteBombInfo(int rbLeft)
    {
        this.remoteBombLeft = rbLeft;
    }

    public void destroyGameObject(int id)
    {
        if (gameObjs.containsKey(id))
        {
            gameObjs.remove(id);
        }
    }

    public void refreshScreen()
    {
        this.panel.repaint();
    }

    public void updateScore(int score)
    {
        this.score = score;
    }
}
