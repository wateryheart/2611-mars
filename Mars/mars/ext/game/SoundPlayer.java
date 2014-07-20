package mars.ext.game;

import java.applet.Applet;
import java.applet.AudioClip;
import java.net.URL;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

public class SoundPlayer
{
    private static String SOUND_DIR = "/sounds/";
    private static final String[] soundFNms = {"background.wav", "bomb.wav",
            "key.wav", "lose.wav", "win.wav", "hit.au"};
    private HashMap<Integer, AudioClip> soundsMap; 
    private ArrayList<Integer> loopSounds;
    public SoundPlayer()
    {
        loopSounds = new ArrayList<Integer>();
        loadSounds();
    }

    private void loadSounds()
    {
        soundsMap = new HashMap<Integer, AudioClip>();
        for (int i = 0; i < soundFNms.length; i++)
        {

            URL url = getClass().getResource(SOUND_DIR + soundFNms[i]);
            if (url == null)
            {
                System.out.println("Url is null!");
            }
            AudioClip clip = Applet.newAudioClip(getClass().getResource(
                    SOUND_DIR + soundFNms[i]));
            if (clip == null)
            {
                System.out.println("Problem loading " + SOUND_DIR
                        + soundFNms[i]);
            }
            else
            {
                soundsMap.put(i, clip);
            }
        }
    } // end of loadSounds()

    public void play(int soundId, boolean toLoop)
    {
        AudioClip audioClip = (AudioClip) soundsMap.get(soundId);
        if (audioClip == null)
        {
            System.out.println("No clip for " + soundId);
            return;
        }
        if (toLoop)
        {
            audioClip.loop();
            loopSounds.add(soundId);
        }
        else
        {
            audioClip.play();
        }
    }
    
    public void stopSound(int soundId)
    {
        AudioClip audioClip = soundsMap.get(soundId);
        if (audioClip == null)
        {
            System.out.println("No clip for " + soundId);
            return;
        }
        audioClip.stop();
        if (loopSounds.contains(soundId))
        {
            loopSounds.remove(soundId);
        }
    }
    
    public void stopAll()
    {
        for (int i = 0; i < loopSounds.size(); ++i)
        {
            int id = loopSounds.get(i);
            if (soundsMap.containsKey(id))
            {
                soundsMap.get(id).stop();
            }
        }
        loopSounds.clear();
    }
    
    /*public static void main(String args[])
    {
        SoundPlayer player = new SoundPlayer();
        player.play(3, false);
    }*/
}
