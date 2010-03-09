/*
	Copyright (C) 2004  Jim Garretson

	This program is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; either version 2 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to the Free Software
	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

import java.lang.reflect.Method; // allows introspection (to find methods in parent BApplet).
import java.util.Calendar; // contains Timestamp.

/**
 * @author Jim Garretson
 * @email jsgarretson@alumni.cmu.edu
 * 
 * Animation: an animation class for Processing.
 * @version 1.0
 */
public class Animation extends BApplet
{

	// private constants
	private static final int REPEAT_FOREVER = 0;
	private static final float POINT_UNDEF = (float)-1.0;
	private static final long TIME_UNDEF = -1;
	private static final int FRAMES_UNDEF = -1;

	// reference to parent applet: used to find methods for callbacks.
	private BApplet parent = null;
		
	// the image to display
	private BImage img = null;
	
	// the animation to pass-through
	private Animation anim = null;
		
	// animation rectangle
	private float x = POINT_UNDEF;
	private float y = POINT_UNDEF;
	private float w = POINT_UNDEF;
	private float h = POINT_UNDEF;

	// dimensions of img.	
	private float img_w = POINT_UNDEF;
	private float img_h = POINT_UNDEF;
	
	// current location of item animating (be it an Animation or a BImage).
	private float current_x = POINT_UNDEF;
	private float current_y = POINT_UNDEF;
	
	// registration points for target BImage or Animation.
	private float reg_x = POINT_UNDEF;
	private float reg_y = POINT_UNDEF;
	
	// flag determining whether or not to draw the animation rectangle each frame.
	private boolean draw_rect = false;
	
	// number of times animation repeats
	private long repetitions_target = 1;
	
	// number of times animation has repeated so far.
	private long repetitions = 0;

	// time (ms) for how long the animation last.
	private long duration_target = TIME_UNDEF;		
	
	// time (UNIX timestamp; ms) when the animation began.
	private long start = TIME_UNDEF;

	// number of frames the animation lasts.
	private int frames_target = FRAMES_UNDEF;
	
	// number of frames drawn so far.
	private int frames = 0;
		
	// Method to test to see if animation has ended. (Cannot take parameters; must return boolean.)
	private Method anim_test = null;
		
	// Method to call when animation ends. (Cannot take or return any parameters.)
	private Method anim_end = null;
		
	// Method to call in order to get an (x,y) coordinate. Passed the percent complete (float; one-quarter finished is 0.25) or percent*100 (int; one-quarter finished is 25); returns array of size 2, of type int[] or float[], where the 0th index is the new x, and the 1th index is the new y.
	private Method anim_step = null;
	
	// supporting vars used to explain the state of anim_step.
	private boolean anim_step_returns_ints = true; // if false, it returns floats.
	private boolean anim_step_takes_int = true; // if false, it takes a long.
	private boolean internal_step_method = false; // true if method to be called is defined in this class, not the parent.
	
	// state of the whole animation.
	private boolean done = false;
	
	// link to image() method in the parent.
	private Method image_method = null;

	
	/**
	 * Constructor. (img-float version.) Sets up the image to render and the animation rectangle.
	 * Sets defaults which are overridden using other methods.
	 * 		Duration = 1 second (1000 ms)
	 * 		Movement = diagonal across the animation rectangle.
	 * 		Repetitions = infinite
	 * 
	 * @param parent The BApplet that instantiates this class. (Used to find methods for callbacks.) Probably is "this".
	 * @param img BImage to be rendered.
	 * @param start_x Upper-left x-coordinate of the animation rectangle.
	 * @param start_y Upper-left y-coordinate of the animation rectangle.
	 * @param end_x Lower-right x-coordinate of the animation rectangle.
	 * @param end_y Lower-right y-coordinate of the animation rectangle.
	 */
	public Animation(BApplet parent, BImage img, float start_x, float start_y, float end_x, float end_y)
	{
		init(parent, img, null, start_x, start_y, end_x, end_y, 0 , FRAMES_UNDEF, 1000, null, null, null);
	} // constructor

	/**
	 * Constructor. (img-int version.) Sets up the image to render and the animation rectangle.
	 * Sets defaults which are overridden using other methods.
	 * 		Duration = 1 second (1000 ms)
	 * 		Movement = diagonal across the animation rectangle.
	 * 		Repetitions = infinite
	 * 
	 * @param parent The BApplet that instantiates this class. (Used to find methods for callbacks.) Probably is "this".
	 * @param img BImage to be rendered.
	 * @param start_x Upper-left x-coordinate of the animation rectangle.
	 * @param start_y Upper-left y-coordinate of the animation rectangle.
	 * @param end_x Lower-right x-coordinate of the animation rectangle.
	 * @param end_y Lower-right y-coordinate of the animation rectangle.
	 */
	public Animation(BApplet parent, BImage img, int start_x, int start_y, int end_x, int end_y)
	{
		init(parent, img, null, (float)start_x, (float)start_y, (float)end_x, (float)end_y, 0 , FRAMES_UNDEF, 1000, null, null, null);
	} // constructor
	

	/**
	 * Constructor. (anim-float version.) Sets up the animation to daisy-chain and the animation rectangle.
	 * Sets defaults which are overridden using other methods.
	 * 		Duration = 1 second (1000 ms)
	 * 		Movement = diagonal across the animation rectangle.
	 * 		Repetitions = infinite
	 * 
	 * @param parent The BApplet that instantiates this class. (Used to find methods for callbacks.) Probably is "this".
	 * @param anim Animation to daisy-chain.
	 * @param start_x Upper-left x-coordinate of the animation rectangle.
	 * @param start_y Upper-left y-coordinate of the animation rectangle.
	 * @param end_x Lower-right x-coordinate of the animation rectangle.
	 * @param end_y Lower-right y-coordinate of the animation rectangle.
	 */
	public Animation(BApplet parent, Animation anim, float start_x, float start_y, float end_x, float end_y)
	{
		init(parent, null, anim, start_x, start_y, end_x, end_y, 0 , FRAMES_UNDEF, 1000, null, null, null);
	} // constructor

	/**
	 * Constructor. (anim-int version.) Sets up the animation to daisy-chain and the animation rectangle.
	 * Sets defaults which are overridden using other methods.
	 * 		Duration = 1 second (1000 ms)
	 * 		Movement = diagonal across the animation rectangle.
	 * 		Repetitions = infinite
	 * 
	 * @param parent The BApplet that instantiates this class. (Used to find methods for callbacks.) Probably is "this".
	 * @param anim Animation to daisy-chain.
	 * @param start_x Upper-left x-coordinate of the animation rectangle.
	 * @param start_y Upper-left y-coordinate of the animation rectangle.
	 * @param end_x Lower-right x-coordinate of the animation rectangle.
	 * @param end_y Lower-right y-coordinate of the animation rectangle.
	 */
	public Animation(BApplet parent, Animation anim, int start_x, int start_y, int end_x, int end_y)
	{
		init(parent, null, anim, (float)start_x, (float)start_y, (float)end_x, (float)end_y, 0 , FRAMES_UNDEF, 1000, null, null, null);
	} // constructor

	
	/**
	 * Sets up the Animation. Called by every constructor -- this does all the work.
	 * 
	 * @param parent The BApplet that instantiates this class. (Used to find methods for callbacks.) Probably is "this".
	 * @param img BImage to be rendered.
	 * @param anim Animation to be daisy-chained with this one.
	 * @param x Upper-left x-coordinate of animation rectangle.
	 * @param y Upper-left y-coordinate of animation rectangle.
	 * @param w Width of animation rectangle.
	 * @param h Height of animation rectangle.
	 * @param repetitions_target Number of times to repeat the animation.
	 * @param frames_target Number of frames to draw before the animation ends.
	 * @param duration_target Number of milliseconds the animation takes.
	 * @param anim_test Name of method in parent BApplet to test in order to end the animation. (Cannot take parameters; must return boolean.)
	 * @param anim_end Name of method in parent BApplet to call when this animation ends. (Cannot take or return any parameters.)
	 * @param anim_step Name of method in parent BApplet to call in order to get the new position of the image. (Passed the percent complete (float; one-quarter finished is 0.25) or percent*100 (int; one-quarter finished is 25); returns array of size 2, of type int[] or float[], where the 0th index is the new x, and the 1th index is the new y.)
	 */
	private void init(BApplet parent,BImage img, Animation anim, float x, float y, float w, float h, long repetitions_target, int frames_target, long duration_target, String anim_test, String anim_end, String anim_step)
	{
		if (parent == null)
		{
			System.err.println("Error in Animation constructor: must pass reference to calling applet (probably \"this\").");
			return;
		}
		
		// record start time of animation.
		start = now();
		
		// copy over params.
		this.parent = parent;
		this.img = img;
		this.anim = anim;
		this.current_x = this.x = x;
		this.current_y = this.y = y;
		this.w = w;
		this.h = h;
		this.repetitions_target = repetitions_target;
		this.frames_target = frames_target;
		this.duration_target = duration_target;		
		
		// record img dimensions.
		if (img != null)
		{
			img_w = (float)img.width;
			img_h = (float)img.height;
		}
		
		// initialize registration point to (0,0) == top-left corner.
		reg_x = reg_y = 0;

		// find methods.
		setAnimTest(anim_test);
		setAnimEnd(anim_end);
		setAnimStep(anim_step);
		
		// retrieve image(BImage, float, float, float, float) Method from parent.
		Class image_args[] = { BImage.class, Float.TYPE, Float.TYPE, Float.TYPE, Float.TYPE };
		try { image_method = parent.getClass().getMethod("image", image_args); } catch (Exception e) { System.err.println("Animation draw internal error: Couldn't find image()."); }
		
		// ensure we have a way to calculate length of the animation. shouldn't fail if the calling method is well-behaved.
		if (this.anim_test == null && this.frames_target == FRAMES_UNDEF && this.duration_target == TIME_UNDEF)
		{
			System.err.println("Animation init internal error: no way to determine length of animation.");
			done = true;	
		}
		
	} // init


	/**
	 * Looks for and sets the method to call before drawing the animation each frame.
	 * 
	 * @param anim_test Name of the Method in the parent BApplet.
	 */
	private void setAnimTest(String anim_test)
	{
		if (anim_test == null)
			return;
	
		// empty Class array -- passed to getMethod()
		Class no_params[] = {};
		
		// resolve anim_test -- it must take no parameters and return a boolean.
		// we know what the prototype looks like, so we can find it using getMethod() .
		this.anim_test = getMethod(anim_test, parent.getClass(), no_params);			
		if (this.anim_test != null)	
		{
			// ensure it returns type boolean
			if (! this.anim_test.getReturnType().getName().equals("boolean"))
			{
				System.err.println("Error: animation-test method named \"" + anim_test + "\"  returns " + this.anim_test.getReturnType().getName() + "; it must return boolean.");
				done = true;	
			}
			//DEBUG
			//else
			//	System.err.println("(anim_test is ok.)");
		}
		else
		{
			System.err.println("Error: valid animation-test method named \"" + anim_test + "\"  not found. It must not take any parameters.");
			done = true;		
		}
	} // setAnimTest
	
	/**
	 * Returns the x-coordinate of the animation rectangle.
	 * 
	 * @return float representing the upper-left animation rectangle x-value.
	 */
	public float x()
	{
		return x;
	} // x

	/**
	 * Returns the y-coordinate of the animation rectangle.
	 * 
	 * @return float representing the upper-left animation rectangle y-value.
	 */
	public float y()
	{
		return y;
	} // y
	
	/**
	 * Returns the width of the animation rectangle.
	 * 
	 * @return float representing the width of the animation rectangle.
	 */
	public float w()
	{
		return w;
	} // w

	/**
	 * Returns the height of the animation rectangle.
	 * 
	 * @return float representing the height of the animation rectangle.
	 */
	public float h()
	{
		return h;
	} // h
	
	/**
	 * Returns the BImage being drawn (if any.)
	 * 
	 * @return the BImage being drawn, or null if it doesn't exist.
	 */
	public BImage image()
	{
		return img;
	} // image
	

	/**
	 * Returns the Animation being drawn (if any.)
	 * 
	 * @return the Animation being drawn, or null if it doesn't exist.
	 */
	public Animation animation()
	{
		return anim;
	} // animation
	
	/**
	 * Returns the current width of the BImage being drawn (or 0 if no image exists), NOT the original image width (use image().width to get that)
	 * 
	 * @return the current width of the BImage being drawn, or POINT_UNDEF if no image exists.
	 */
	public float imageWidth()
	{
		return img_w;
	} // imageWidth

	/**
	 * Returns the current height of the BImage being drawn (or 0 if no image exists), NOT the original image height (use image().height to get that)
	 * 
	 * @return the current height of the BImage being drawn, or POINT_UNDEF if no image exists.
	 */
	public float imageHeight()
	{
		return img_h;
	} // imageHeight

	/**
	 * Returns the number of repetitions for this Animation to perform. (This can be changed using setRepetitions().)
	 * 
	 * @return the currently set number of repetitions to perform.
	 */
	public long repetitions()
	{
		return repetitions_target;
	} // repetitions
	

	/**
	 * Returns a counter representing how many repetitions have been performed so far.
	 * 
	 * @return a counter representing how many repetitions have been performed so far.
	 */
	public long currentRepetition()
	{
		return repetitions;
	} // currentRepetition
	
	/**
	 * Returns the current y-component of the animated item's location (be it a BImage or an Animation).
	 * 
	 * @return float representation of y-component of current location.
	 */
	public float currentY()
	{
		return current_y;
	} // currentY
	

	/**
	 * Returns the current x-component of the animated item's location (be it a BImage or an Animation).
	 * 
	 * @return float representation of x-component of current location.
	 */
	public float currentX()
	{
		return current_x;
	} // currentX
	

	/**
	 * Returns the current percentage complete of the Animation.
	 * 
	 * @return a decimal representing the percent complete that the Animation currently is, or -1.0 if unknown.
	 */
	public float currentPercentage()
	{
		if (frames_target != FRAMES_UNDEF)
			return (float)frames / (float)frames_target;
		else if (duration_target != TIME_UNDEF)
			return (float)(now() - start) / (float)duration_target;
		else
			return -1f;
	} // currentPercentage
	

	/**
	 * Looks for and sets the method to call when the animation ends.
	 * 
	 * @param anim_test Name of the Method in the parent BApplet.
	 */
	private void setAnimEnd(String anim_end)
	{
		// resolve anim_end -- it cannot take or return any parameters.
		// we know what the prototype looks like, so we can find it using getMethod() .
		if (anim_end == null)
			return;
		
		// empty Class array -- passed to getMethod()
		Class no_params[] = {};
	
		this.anim_end = getMethod(anim_end, parent.getClass(), no_params);
		if (this.anim_end != null)	
		{
			// ensure it returns type void
			if (! this.anim_end.getReturnType().getName().equals("void"))
			{
				System.err.println("Error: valid animation-end method named \"" + anim_end + "\"  returns " + this.anim_end.getReturnType().getName() + "; it must return void.");
				done = true;		
			}
			//DEBUG
			//else
			//	System.err.println("(anim_end is ok.)");
		}
		else
		{
			System.err.println("Error: valid animation-end method named \"" + anim_end + "\" not found. It must not take any parameters.");
			done = true;		
		}
		
	}// setAnimEnd
	

	/**
	 * Looks for and sets the method to call in order to update the animation rectangle each frame before drawing.
	 * Looks first in the 'this' Animation object, and if not found, then in the parent BApplet.
	 * 
	 * @param anim_test Name of the Method in the parent BApplet.
	 */
	private void setAnimStep(String anim_step)
	{
		// resolve anim_step
		if (anim_step == null)
			return;

		// there are four possible valid prototypes:
		//	1. int[]	anim_step	(int)
		//	2. int[]	anim_step	(float)
		//	3. float[]	anim_step	(int)
		//	4. float[]	anim_step	(float)
		// we'll need to figure out which, if any, it is.			

		Class int_param[] = { Integer.TYPE };
		Class float_param[] = { Float.TYPE };
		boolean found_within_this = true;

		// ***** CHECK THIS ANIMATION OBJECT		
		
		// check for param as int
		this.anim_step = getMethod(anim_step, this.getClass(), int_param);
		if (this.anim_step == null)
		{
			// check for param as float
			this.anim_step = getMethod(anim_step, this.getClass(), float_param);
			if (this.anim_step == null)
				found_within_this = false;	
			else
				this.anim_step_takes_int = false;
		}
		else
			this.anim_step_takes_int = true;


		if (found_within_this)
			internal_step_method = true;
		// if method wasn't found, check the parent.
		if (! found_within_this)
		{
			
			// ***** CHECK PARENT
	
			// check for param as int
			this.anim_step = getMethod(anim_step, parent.getClass(), int_param);
			if (this.anim_step == null)
			{
				// check for param as float
				this.anim_step = getMethod(anim_step, parent.getClass(), float_param);
				if (this.anim_step == null)
				{
					System.err.println("Error: valid animation-step method named \"" + anim_step + "\" not found. It must take either an int or float as the only parameter.");
					done = true;	
					return;		
				}
				else
					this.anim_step_takes_int = false;
			}
			else
				this.anim_step_takes_int = true;
			
		}// look for method in parent
		

		// at this point, anim_step has been found. Now we need to ensure it returns int[] or float[]
		if (! this.anim_step.toString().substring(0, this.anim_step.toString().indexOf(" ")).equals("int[]"))
		{
			if (! this.anim_step.toString().substring(0, this.anim_step.toString().indexOf(" ")).equals("float[]"))
			{
				System.err.println("Error: animation-step method \"" + anim_step + "\" must return either int[] or float[].");
				done = true;	
				return;					
			}
			else
				this.anim_step_returns_ints = false;
		}
		else
			this.anim_step_returns_ints = true;
		//DEBUG
		//System.err.println("(anim_step is ok.)");

	} // setAnimStep
	
	
	/**
	 * Returns the Method named s, in class c.
	 * @param s String representation of the Method to find.
	 * @param c Class in which the Method to find resides.
	 * @param args array of Classes corresponding to the Method's arguments.
	 * @return The Method, or null if it didn't exist.
	 */
	private Method getMethod(String s, Class c, Class args[])
	{
		try { return  c.getDeclaredMethod(s,args); } catch (Exception e) { return null; }
	} // getMethod


	/**
	 * Helper method to retrieve the system time.
	 * 
	 * @return UNIX timestamp for (RIGHT NOW).
	 */
	private long now()
	{
		return Calendar.getInstance().getTimeInMillis();
	} // now


	/**
	 * Invokes the method underlying the anim_test variable.
	 * 
	 * @return the return value of anim_test, or false if anim_test was null.
	 */
	private boolean runAnimTest()
	{
		try
		{
			return ((Boolean)anim_test.invoke(parent, null)).booleanValue();
		}
		catch (Exception e)
		{
			System.out.println("Error: exception while executing animation-test method \"" + anim_test + "\": " + e.getMessage());
			done = true;	
			return false;
		}
	} // runAnimTest
	

	/**
	 * Invokes the method underlying the anim_end variable.
	 * 
	 */
	private void runAnimEnd()
	{
		try
		{
			anim_end.invoke(parent, null);
		}
		catch (Exception e)
		{
			System.out.println("Error: exception while executing animation-end method \"" + anim_end + "\": " + e.getMessage());
			
			// in the interests of completeness:
			done = true;	
		}
	} // runAnimEnd

	/**
	 * Sets the duration of the animation, in milliseconds. (Default is 1000ms.)
	 * This call overrides any previous durations or frames values.
	 * 
	 * @param how_long Duration of the animation, in ms. (1 second = 1000 ms.)
	 */
	public void setDuration(long how_long)
	{
		if (how_long < 1)
			System.err.println("Animation error: Cannot draw for " + how_long + " milliseconds. Please set to a positive number.");
		else
		{	
			duration_target = how_long;
			frames_target = FRAMES_UNDEF;
		}
	} // setDuration
	

	/**
	 * Sets the duration of the animation, in frames.
	 * This call overrides any previous durations or frames values.
	 * 
	 * @param how_many Duration of the animation, in frames. (See proce55ing framerate() command.)
	 */
	public void setFrames(int how_many)
	{
		if (how_many < 1)
			System.err.println("Animation error: Cannot draw " + how_many + " frames. Please set to a positive number.");
		else
		{
			frames_target = how_many;
			duration_target = TIME_UNDEF;
		}
	} // setFrames
	
	/**
	 * Resets the registration point to (0,0) == top left corner of animation-rectangle.
	 *
	 */
	public void resetRegistrationPoint()
	{
		reg_x = reg_y = 0;
	} // resetRegistrationPoint
	
	/**
	 * Sets the BImage or Animation's registration point (point at which position is calculated). Default is (0,0) == top-left corner of animation-rectangle.
	 * 
	 * @param x x-component of desired registration point.
	 * @param y y-component of desired registration point.
	 */
	public void setRegistrationPoint(float x, float y)
	{
		reg_x = x;
		reg_y = y;
	} // setRegistrationPoint
	
	
	/**
	 * Returns the currently set registration point's x-component.
	 * 
	 * @return the currently set registration point's x-component (as a float.)
	 */
	public float currentRegistrationPointX()
	{
		return reg_x;
	} // getRegistrationPointX
	

	/**
	 * Returns the currently set registration point's y-component.
	 * 
	 * @return the currently set registration point's y-component (as a float.)
	 */
	public float currentRegistrationPointY()
	{
		return reg_y;
	} // getRegistrationPointY
	
	
	/**
	 * Sets the number of times the animation should play. (Default is 1.)
	 * Set to 0 to make the animation repeat forever.
	 * 
	 * @param how_many Number of times the animation should play.
	 */
	public void setRepetitions(int how_many)
	{
		if (how_many < 0)
			System.err.println("Animation error: Cannot repeat an animation " + how_many + " times. Please set to a positive number, or to 0 to repeat forever.");
		else
			repetitions_target = how_many;
	} // setRepetitions
	
	/**
	 * Sets the Animation as finished. DOES NOT run animation-end method. To start it again, use reset().
	 *
	 */
	public void setDone()
	{
		done = true;		
	} // setDone
	
	/**
	 * Returns the state of the Animation.
	 * 
	 * @return true if the Animation is done; false otherwise.
	 */
	public boolean done()
	{
		return done;
	} // done
	
	/**
	 * Sets a custom method to call before each drawing of the animation, to check if the animation has ended.
	 * The method passed must take no parameters, and return type boolean. (return true if the animation ends.)
	 * 
	 * @param test_method_name String representation of the method, eg. test() would be passed as "test".
	 */
	public void setTest(String test_method_name)
	{
		if (test_method_name == null)
			System.err.println("Animation error: setTest() method name was null.");
		else
			setAnimTest(test_method_name);	
	} // setTest
	

	/**
	 * Sets a custom method to call when the animation has ended. (If an animation repeats many times, the method is called after the last repetition ends.)
	 * The method passed must take no parameters, and return type void.
	 * 
	 * @param end_method_name String representation of the method, eg. end() would be passed as "end".
	 */
	public void setEnd(String end_method_name)
	{
		if (end_method_name == null)
			System.err.println("Animation error: setEnd() method name was null.");
		else
			setAnimEnd(end_method_name);	
	} // setEnd
	

	/**
	 * Sets a custom method to call immediately before drawing the animation each time, to get update end (x,y) values.
	 * If null is passed, the step function reverts to the default diagonal across the animation-rectangle.
	 * 
	 * The method passed must take a single parameter as either an int or float:
	 * 		int: An integer value is passed representing the percentage complete the animation is, eg. 10% complete would be passed as 10.
	 * 		float: A float value is passed representing the percentage complete the animation is, eg. 10% complete would be passed as 0.1 .
	 * The method must return either int[] or float[]. The 0th index contains the new X value, and the 1th index contains the new Y value.
	 * 
	 * @param step_method_name String representation of the method, eg. step() would be passed as "step".
	 */
	public void setStep(String step_method_name)
	{
		if (step_method_name == null)
			anim_step = null;
		else
			setAnimStep(step_method_name);	
	} // setStep
	
	/**
	 * Sets new width for the BImage-to-draw.
	 * 
	 * @param img_w New width of the BImage to draw.
	 */
	public void setImageWidth(float img_w)
	{
		this.img_w = img_w;
	} // setImageWidth

	/**
	 * Sets new height for the BImage-to-draw.
	 * 
	 * @param img_h New height of the BImage to draw.
	 */
	public void setImageHeight(float img_h)
	{
		this.img_h = img_h;
	} // setImageHeight
	
	
	/**
	 * Changes the animation rectangle to the specified boundaries.
	 * (float version.)
	 *
	 * @param x Upper-left x-coordinate of animation rectangle.
	 * @param y Upper-left y-coordinate of animation rectangle.
	 * @param w Width of animation rectangle.
	 * @param h Height of animation rectangle.
	 */
	public void setRectangle(float x, float y, float w, float h)
	{
		// alter current_x and current_y so they match with the new x,y.
		this.current_x += x - this.x;
		this.current_y += y - this.y;
		
		this.x = x;
		this.y = y;
		this.w = w;
		this.h = h;
	} // setRectangle
	

	/**
	 * Changes the animation rectangle to the specified boundaries.
	 * (int version.)
	 *
	 * @param x Upper-left x-coordinate of animation rectangle.
	 * @param y Upper-left y-coordinate of animation rectangle.
	 * @param w Width of animation rectangle.
	 * @param h Height of animation rectangle.
	 */
	public void setRectangle(int x, int y, int w, int h)
	{
		setRectangle((float)x, (float)y, (float)w, (float)h);
	} // setRectangle

	
	/**
	 * Changes the image to draw for each frame of the animation.
	 * 
	 * @param img BImage to render.
	 */
	public void setImage(BImage img)
	{
		if (img == null)
			System.err.println("Animation error: setImage() specified BImage was null.");
		else
			this.img = img;
	} // setImage
	

	/**
	 * Changes the nested animation to draw for each frame of the animation.
	 * 
	 * @param img BImage to render.
	 */
	public void setAnimation(Animation anim)
	{
		if (anim == null)
			System.err.println("Animation error: setAnimation() specified Animation was null.");
		else
			this.anim = anim;
	} // setAnimation
	
	
	/**
	 * Sets the animation rectangle's visibility to false (hidden).
	 * The specifics of the rectangle's rendering depend on how the proce55ing flags are set. ( stroke(), fillMode(), rectMode(), etc. )
	 */
	public void hideRectangle()
	{
		draw_rect = false;
	} // hideRectangle
	
	/**
	 * Sets the animation rectangle's visibility to true.
	 * The specifics of the rectangle's rendering depend on how the proce55ing flags are set. ( stroke(), fillMode(), rectMode(), etc. )
	 */
	 public void showRectangle()
	 {
		draw_rect = true;
	 } // showRectangle
	 
	/**
	 * Returns visibility of the animation-rectangle.
	 * @return true if the animation-rectangle is visible.
	 */
	 public boolean rectangleVisible()
	 {
		return draw_rect;
	 } // rectangleVisible
	 
	 
	 /**
	  * Resets the animation -- resets repetitions and frames & duration counters to 0, and makes imageHeight() and imageWidth() equal to the original image's dimensions.
	  */
	 public void reset()
	 {
		start = now();
		frames = 0;
		repetitions = 0;
		done = false;
	 } // reset

	/**
	 * Draws the current animation frame. This should probably be called inside the proce55ing loop() method.
	 */
	public void draw()
	{
	
		// first of all, is the animation over?
		if (done)
			return;

		if (img == null && anim == null)
		{
			System.err.println("Animation error: Can't draw; neither an image nor a nested Animation have been defined.");
			return;
		}
		
		// ***** update time-based state.

		
		//DEBUG
		//System.err.println("duration_target: " + duration_target);
		//System.err.println("elapsed: " + (now() - start));
		//System.err.println("frames_target: " + frames_target);

		// if there's a test method, check it.
		if (anim_test != null)
		{
			if (runAnimTest())
			{
				done = true;
				if (anim_end != null)
					runAnimEnd();
				return;
			}		
		} 

		// then check duration and frame targets
		if (
			// check duration target for completion
			( (duration_target != TIME_UNDEF) && (duration_target <= (now() - start)) )
		||
			// check frames target for completion
			( (frames_target != FRAMES_UNDEF) && (frames_target <= frames) )
		)
		{
			// roll over if max size is reached.
			if (repetitions == Long.MAX_VALUE)
				repetitions = 1;
			else
				repetitions++;				
			//DEBUG
			//System.err.println("finished an animation. target is " + repetitions_target);
			if (repetitions_target != REPEAT_FOREVER)
			{
				// stop if we've repeated the appropriate number of repetitions.
				 if (repetitions_target <= repetitions)
				{
					done = true;
					if (anim_end != null)
						runAnimEnd();
					return;
				}
			}
			
			// else we're to REPEAT_FOREVER: reset the animation (but not the repetitions counter)
			start = now();
			frames = 0;
			if (img != null)
			{
				img_w = img.width;
				img_h = img.height;
			}

		} // update time-based state.


		// ***** calculate & use animation step to draw new position.
		
		
		// calculate % complete.
		float percent_complete = 0;
		if (frames_target != FRAMES_UNDEF)
		{
			percent_complete = (float)frames / (float)frames_target;
			
			// update frame counter, for next time.
			frames++;	
		}
		else if (duration_target != TIME_UNDEF)
		{
			percent_complete = (float)(now() - start) / (float)duration_target;
			//System.err.println("pc: " + percent_complete);
		}
		else
		{
			// we've neither a frame nor a duration target -- should've been caught in init().
			System.err.println("Animation draw internal error: no way to determine location in animation. Giving up.");
			done = true;
			return;
		} 
		

		// draw the animation rectangle, if requested.
		// (draw it before the image is drawn, so the image is on top if a fill() is set.)
		if (draw_rect)
		{
			Method rect_method = null;
			
			// retrieve rect(float, float, float, float) Method from parent.
			Class rect_args[] = { Float.TYPE, Float.TYPE, Float.TYPE, Float.TYPE };
			try { rect_method = parent.getClass().getMethod("rect", rect_args); } catch (Exception e) { System.err.println("Animation draw internal error: Couldn't find rect()."); }

			Object rect_invoke_params[] = {new Float(x), new Float(y), new Float(w), new Float(h) };
			try { rect_method.invoke(parent, rect_invoke_params); } catch (Exception e) { System.err.println("Animation draw internal error: Couldn't call rect()."); }
		}	
		
		
		// vars to hold the next calculated draw position.
		float draw_x = POINT_UNDEF;
		float draw_y = POINT_UNDEF;
		
		// use anim_step, if there is one.
		if (anim_step != null)
		{
			try
			{		
				// send an int
				if (anim_step_takes_int)
				{
					Object int_param[] = { new Integer((int)(100.0 * percent_complete)) };
		
					if (anim_step_returns_ints)
					{
						int int_step[] = (int[])anim_step.invoke(internal_step_method ? this : parent, int_param);
						if (int_step.length != 2)
						{
							System.err.println("Animation draw error: animation-step method \"" + anim_step + "\" must return array of size 2.");
							done = true;		
						}
						else
						{
							draw_x = (float)int_step[0];
							draw_y = (float)int_step[1];
						}
					}	
					else // returns floats
					{
						float float_step[] = (float[])anim_step.invoke(internal_step_method ? this : parent, int_param);
						if (float_step.length != 2)
						{
							System.err.println("Animation draw error: animation-step method \"" + anim_step + "\" must return array of size 2.");
							done = true;		
						}
						else
						{
							draw_x = float_step[0];
							draw_y = float_step[1];
						}	
					}
				}
				
				// else send a float
				else
				{

					Object float_param[] = { new Float(percent_complete) };
		
					if (anim_step_returns_ints)
					{
						int int_step[] = (int[])anim_step.invoke(internal_step_method ? this : parent, float_param);
						if (int_step.length != 2)
						{
							System.err.println("Animation draw error: animation-step method \"" + anim_step + "\" must return array of size 2.");
							done = true;		
						}
						else
						{
							draw_x = (float)int_step[0];
							draw_y = (float)int_step[1];
						}	
					}	
					else // returns floats
					{
						float float_step[] = (float[])anim_step.invoke(internal_step_method ? this : parent, float_param);
						if (float_step.length != 2)
						{
							System.err.println("Animation draw error: animation-step method \"" + anim_step + "\" must return array of size 2.");
							done = true;		
						}
						else
						{
							draw_x = float_step[0];
							draw_y = float_step[1];
						}	
					}	
				}
			}
			catch (Exception e)
			{
				System.err.println("Animation draw internal error: couldn't invoke animation-step method: " + e.getMessage());
				done = true;	
			}
		}
		
		// otherwise, we'll just make a linear diagonal across the rectangle.
		else
		{
			//DEBUG
			//System.out.println("making default movement");
			draw_x = (x + w*percent_complete);
			draw_y = (y + h*percent_complete);			
		}
		
		//DEBUG
		//System.out.println("drawing.");
		// perform draw with the new position
		
		// record new position.
		current_x = draw_x;
		current_y = draw_y;
		
		// actually draw the image -- include registration point in draw position.
		if (img != null)
		{		
			Object image_method_params[] = { img, new Float(current_x - reg_x), new Float(current_y - reg_y), new Float(img_w), new Float(img_h) };
			try { image_method.invoke(parent, image_method_params); } catch (Exception e) { System.err.println("Animation draw internal error: Couldn't call image()."); }
		}
		// alter the child animation rectangle location (not size) and draw it -- include registration point in draw position.
		if (anim != null)
		{
			anim.setRectangle(current_x - reg_x, current_y - reg_y, anim.w(), anim.h());
			anim.draw();
		}
		
		
	} // draw
	
	
	/**
	 * Predefined step function: motion traces an ellipse contained within the animation box.
	 * 
	 * @param percent percentage complete that the animation is.
	 * @return array of new x,y position.
	 */
	float[] ELLIPSE (float percent)
	{
		float return_values[] = new float[2];
		
		return_values[0] = x() + w()/2f + w()/2f*cos(percent * TWO_PI);
		return_values[1] = y() + h()/2f + h()/2f*sin(percent * TWO_PI);
		
		return return_values;
	} // ELLIPSE
	

	/**
	 * Predefined step function: motion traces the boundaries of the animation box.
	 * 
	 * @param percent percentage complete that the animation is.
	 * @return array of new x,y position.
	 */
	float[] BOX (float percent)
	{
		float return_values[] = new float[2];
		
		// along top wall
		if (percent < 0.25)
		{
			return_values[0] = x() + (percent*4f)*w();
			return_values[1] = y();	
		}
		
		// along right wall
		else if (percent < 0.5)
		{
			return_values[0] = x()+w();
			return_values[1] = y() + ((percent-0.25f)*4f)*h();	
		}
		
		// along bottom wall
		else if (percent < 0.75)
		{
			return_values[0] = x()+w() - ((percent-0.5f)*4f)*w();
			return_values[1] = y()+h();
		}
		
		// along left wall
		else
		{
			return_values[0] = x();
			return_values[1] = y()+h() - ((percent-0.75f)*4f)*h();	
		}
		
		return return_values;
	} // BOX
	

	/**
	 * Predefined step function: motion traces linear motion across the box diagonally, then "bounces" back.
	 * 
	 * @param percent percentage complete that the animation is.
	 * @return array of new x,y position.
	 */
	float[] BOUNCE (float percent)
	{
		float return_values[] = new float[2];

		if (percent < 0.5)
		{
			return_values[0] = x() + (percent*2f)*w();
			return_values[1] = y() + (percent*2f)*h();
		}
		else
		{
			return_values[0] = x()+w() - ((percent-0.5f)*2f)*w();
			return_values[1] = y()+h() - ((percent-0.5f)*2f)*h();
		}
		
		return return_values;
	} // BOUNCE
	

	/**
	 * Predefined step function: does nothing. animation returns its current position.
	 * 
	 * @param percent percentage complete that the animation is.
	 * @return (0,0)
	 */
	float[] NONE (float percent)
	{
		return new float[] {currentX(),currentY()};
	} // NONE
	

	/**
	 * Predefined step function: scales target image from original size to box size. (Image is centered in the box.)
	 * 
	 * @param percent percentage complete that the animation is.
	 * @return array containing the animaton rectangle's (x,y) position. (unchanged, in this case.)
	 */
	float[] SCALE (float percent)
	{
		// this is necessary to avoid null-pointer exceptions if this motion is applied to a nested animation, not an image.
		if (this.image() != null)
		{
			// scale the image's width and height according to the given percentage. 
			this.setImageWidth(image().width + percent*(w()-image().width));
			this.setImageHeight(image().height + percent*(h()-image().height));
		}
		
		// return x and y moved as the image scales.
		float return_values[] = { x()+w()/2-imageWidth()/2, y()+h()/2-imageHeight()/2   };	
		return return_values;	
	} // SCALE
	

	/**
	 * Predefined step function: bounces off the walls of its rectangle pseudorandomly.
	 * 
	 * @param percent percentage complete that the animation is.
	 * @return array containing the animaton rectangle's (x,y) position.
	 */
	float[] NOISE(float percent)
	{
		// set up vector: 0th is x, 1th is y. (true means positive.)
	 	if (noise_vector == null)
		{
			noise_vector = new boolean[2];
			noise_vector[0] = Math.random() > 0.5d ? true : false;
			noise_vector[1] = Math.random() > 0.5d ? true : false;
		}
	 	
	 	float new_position[] = new float[2];
	   
	    // bump positions by a random amount between 0 and 2 in the direction of the vectors.
	    new_position[0] = this.currentX() + (float)(Math.random() * 0.75f) * (noise_vector[0] ? 1f : -1f);
	    new_position[1] = this.currentY() + (float)(Math.random() * 0.75f) * (noise_vector[1] ? 1f : -1f);
	  
	    // swap vector +/- if it hits the rectangle border.
	    if (new_position[0] >= this.x() + this.w())
			noise_vector[0] = false;
	    else if (new_position[0] < this.x())
			noise_vector[0] = true;
	  
	    if (new_position[1] >= this.y() + this.h())
			noise_vector[1] = false;
	    else if (new_position[1] < this.y())
			noise_vector[1] = true;
	  
	    return new_position;
	} // NOISE
	 
	// messy, messy: this is used by NOISE.
    private boolean noise_vector[] = null;


} // class Animation
