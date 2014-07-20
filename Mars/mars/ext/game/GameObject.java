package mars.ext.game;

import java.awt.Graphics;

/**
 * This is the Abstract Base Class of all types of objects to be used in the
 * course project of COMP2611 in HKUST.
 * 
 * @author jasonwangm
 * 
 */
public abstract class GameObject {
	protected int id; // each GameObject has a unique non-negative id
	protected int xLoc; // the x-coordinate
	protected int yLoc; // the y-coordinate

	public GameObject(int id) {
		this(id, -1, -1);
	}

	public GameObject(int id, int x, int y) {
		this.id = id;
		this.xLoc = x;
		this.yLoc = y;
	}

	/**
	 * A concrete type of GameObject has its own implementation of how to paint
	 * itself on the Graphics.
	 * 
	 * @param graph
	 */
	public abstract void paint(Graphics graph);

	public int getId() {
		return this.id;
	}

	public void setXLoc(int x) {
		this.xLoc = x;
	}

	public int getXLoc() {
		return this.xLoc;
	}

	public void setYLoc(int y) {
		this.yLoc = y;
	}

	public int getYLoc() {
		return this.yLoc;
	}
	
	public void setLocations(int x, int y) {
		this.xLoc = x;
		this.yLoc = y;
	}
}
