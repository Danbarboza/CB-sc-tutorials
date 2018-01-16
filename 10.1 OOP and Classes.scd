
// Object Oriented Programming (OOP) and Class structures in SuperCollider

/* What is a Class?

Think of a cookie-cutter mold; it is a template from which we can make as many cookies as we like. There is only one mold, but lots of cookies that all look the same.  In object oriented programming we call the mold a 'Class', and the cookies we make from it 'objects' or 'instances'.   A class is an abstract description of properties of some category.  We can make a class for whatever purpose we choose.

SuperCollider is an Object Oriented Programming Language, its classes are all the words that start with capital letters:

SinOsc
LFSaw
LPF

These are the classes that are the abstract descriptions for particular types of audio objects. When we make objects from the recipes, we get particular instances of a sine oscillator, or a low frequency saw wave or a low pass filter. We can have as many sine oscillator objects as we like in our piece, but we create them all from the SinOsc class.

A 'method' is a function that a class, or instances of a class, knows how to execute.  Method definitions are found either within its source file (its Class.sc file), or are inherited from its Superclass, and can therefore be found in (one of) its SuperClasses.  The SinOsc class makes each SinOsc object through a class method of the class, 'ar'.  A class method is just a function, but it is a function tied to a class. The most important class methods are the recipes for making objects, like 'new' */

w=Window.new("new window object", Rect.new(100,100,400,400));

// The 'new' class method is used so commonly in SC, that it is executed by default when arguments are supplied to a class name which has no message.

w= Window("new window object", Rect.new(100,100,400,400));

// As well as class methods, we have instance methods. These are functions which any created instance (object) of a class can respond to.

w.front;	//make window appear by calling an instance method on the instance (object) we just made

//call an instance method 'backColor_' on the view object belonging to the window object
w.view.backColor_(Color.blue);
w.view.backColor_(Color.new255(255,100,45));  // RGB values 0-255

// Note how in the first case we called a function (using the dot) on a class name- SCWindow.new ('new' is a class method) and in the second we called a function on a variable holding an individual object - w.front ('front' is an instance method).

//How do you know what the class methods and instance methods of any class are?

Window		//select the text and press cmd+d to get the Help file, which shows both methods and variables defined in this class, and sublists of methods and variables inherited through superclasses

Window		//select the text and press cmd+I to go to the source code definition

new		//select the text and press cmd+I to see all the classes that respond to new


/*  Class definition files (source code files with posfix '.sc' contain lists of methods. Some have names that begin with a *, like *ar or *new - these are class methods. Some have names with no asterisk - these are instance methods.

In SuperCollider every class you ever make has some position within a class hierarchy. This is a taxonomy of all the different things you can make, and how they relate to one another.

For instance, a SinOsc is a type of UGen (unit generator).
An Array is a type of ArrayedCollection.

This relating of types allows classes to share common properties and avoids the programmer having to code lots of similar functions again and again. */

Collection.dumpClassSubtree //show all classes derived from Collection

/* (For further information on querying the class hierarchy see:[Internal-Snooping]	//select the text within the brackets and press cmd+d

In fact, everything derives at root from a basic class, confusingly called Object. In SuperCollider, all other classes inherit the properties of the Object class. We say that all classes derive from Object. */

Object.dumpClassSubtree		//try running this to see the whole hierarchy

// There is a big tree structure of classes. As we go down the hierarchy from Object, classes become increasingly specialized.  Classes that specialize, that derive from something else, are called subclasses. The class they derive from is the superclass.

// When you create new classes you derive from an existing class using the colon.

SinOsc  : UGen		//SinOsc is a subclass of UGen; UGen is the super class for SinOsc.  This means that SinOsc is a more specialised UGen, one that deals exclusively with making sine waves.

// By default, you derive from Object, so if you don't specify any class to derive from explicitly, you are making a subclass of Object.

// If we were modeling animals, we might create a structure like this:

SavannahBeast: SavannahHerbivore: Giraffe: AlbinoGiraffe

/* A more extensive tree of classes might look like:

						SavannahBeast
						/				\
SavannahCarnivore						SavannahHerbivore
	/			\								/               \
Lion			Hyena						Giraffe
												|
											AlbinoGiraffe

As well as methods, classes and objects can have associated variables. This is because in Object Oriented programming the data is stored with the functions that act on that data. You can see this is common sense, for going back to our Giraffe class, we might want data to tell us how tall an individual giraffe is (held in an instance variable) or we might want data telling us the natural predators of the giraffe species (held in a class variable, since I assume it's the same for every giraffe).

Declared within a class definition:  */

var <>height; 				//is an instance variable
classvar <>predators; 		//is a class variable

// in the client code (the code that uses my hypothetical Giraffe class) I might have:

g= Giraffe.new;
g.height = 2.4; 		//set the height in meters of this particular Giraffe
g.height_(2.4);     // this is another way to write the same thing

Giraffe.predators = [\lion, \hyena, \man];	//set the predators of the entire giraffe species

// Note how the instance variable is called from an instance stored in a variable, but the class variable is called via the class name.

/* An important issue is that of access. Some data is only used internally in a class, for private calculations that normal users don't need to know about; other data is freely available to people who use the class.  This is shown by the < and > signs. < is the getter method, meaning that someone outside the class can read this data.  > is the setter method, meaning that someone outside the class can write new values for this data.

If neither is there, nobody outside the class can access that data, but it is freely available to the code written for the class itself.

So if we have the simple class definition:    */

Giraffe { var <height; }

// I can use:

g=Giraffe.new;
h= g.height; 	      //there is a getter, so I can read the current value

// but I cannot use:
g.height = 2.3;	//there is no setter

/* Using extension libraries and recompiling the library

The SCClassLibrary folder in the SuperCollider application directory contains the basic class definition files (those that end in .sc) which are compiled when you start the application or when you recompile the library using cmd+K to restart the language.

You can install your own classes, as well as extension libraries for SuperCollider that other people have written which will be included in every recompilation of the language. The best way to install such class packages is to put all help files, .sc class files and plugin files (like .scx, .sco and similar) into one of the the platform specific Extensions directories:  */

Platform.userExtensionDir;   // Extensions available only to your user account
Platform.systemExtensionDir;   // Extensions available to all users on the machine

/* These could also be placed in the SuperCollider folder in your Applications directory but it's best not to clutter this folder with your own choice of library extensions because you should periodically update SuperCollider to take advantage of bug-fixes and improvements to the language, and these updates could wipe out your carefully selected and composed class libraries!

The final syntax you just need to be aware of is the use of the claret symbol ^, which is used in the methods (the functions) of the class to denote where a function returns.

In writing your own normal functions, the last statement is automatically returned when the function executes:  */

~myFunc = {arg a; a*a}		//return the square of the argument

// In defining this as an instance method for a class no = sign is used to identify the myFunc name with the function, and you must specify the object that is to be returned with the caret:

myFunc {arg a;  ^a*a}  //

// The reason for the caret is that a method can return at any point, or at multiple points based on the logic:

mymethod {arg a;  if(a==4, ^7);  a=(a*9)%7; ^if(a==6, 5, a)}

// A normal function could not do this.

// Summary of Terminology


object	// something that has data, representing the object's state, and a set of operations that can be performed on the object.

message	//	a request for an object to perform an operation.

receiver // the object to which a message is sent.

class	// a description of the state and behaviour of a set of objects.

interface // the set of messages to which an object responds.

protocol	//a set of messages that implement a specific kind of behaviour.

polymorphism  // the ability for different kinds of objects to respond differently to the same message.

method	// a description of the operations necessary to implement a message for a particular class.

instance	// one of the objects described by a class.

instance variable	// a part of an object's internal state

class variable 	// an object whose value is shared by all objects in the class. Class variable declaration lists are preceeded by the reserved word classvar


