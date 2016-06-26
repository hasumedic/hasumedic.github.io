---
layout: post
title: Scala classes and objects
description: "Main properties and uses for classes and objects in Scala"
category: blog
tags: [scala, classes, objects]
comments: true
image:
    feature: classes-and-objects/IMG_3001.jpg
---

When learning Scala, you often find yourself reading stuff from lots of sources with tons of information about different topics. Hence, it is not difficult to end up going down a rabbit-hole, starting reading about some cool feature or concept and end up 3 hours later trying to understand some obscure type level programming technique/pattern which is not what your original plans were.

So I wanted to go a little bit back to Scala basics in this post, targeting people who are just starting and wants to get familiar with it.

# Classes

"But I heard that Scala was a functional language, shouldn't everything be a function?"

Well, you've heard well. Scala is a functional language, but it's actually more of a hybrid between the OOP and functional worlds.

In order to better organize concepts and units of logic, Scala supports classes. The idea behind them is not that different to their counterparts in Java or C++. Here is an overly simplified example:

{% highlight scala %}
class Lift(val levels: Int) {
    private var level = 0

    def currentLevel() = level
    
    def goUp(levels: Int) = level += levels
    
    def goDown(levels: Int) = level -= levels

    def goesHigherThan(other: Lift) = this.levels > other.levels
}
{% endhighlight %}

We are using the *class* keyword to declare a Lift class. Scala makes it public by default, so there's no need for the redundant "public" Java modifier. To construct objects of this class, the same good old *new* keyword is used:

{% highlight scala %}
val lift = new Lift(10)
{% endhighlight %}

In Scala, class definitions are very concise and accept parameters in their very definition, acting as their primary constructor. These parameters can generate lots of boilerplate code for us. If we specify them with the *val* keyword, a getter method with the same name as the field will be available for us. If instead of val we use *var*, both a getter and a setter will be made available to us:
 
{% highlight scala %}
class Lift(val levels: Int)

val lift = new Lift(10)
lift.levels // Int = 10
lift.levels = 50 // error: reassignment to val

vs

class Lift(var levels: Int)

val lift = new Lift(10)
lift.levels // Int = 10
lift.levels = 50
lift.levels // Int = 50
{% endhighlight %}

Like in Java, private fields from other classes are accessible from the current class as long as their types are the same.

{% highlight scala %}
    def goesHigherThan(other: Lift) = this.levels > other.levels
{% endhighlight %}

We already mentioned the primary constructor, but what if we want to have more ways to instantiate the class? Scala allows us to define auxiliary constructors by using *this* keyword:

{% highlight scala %}
class Lift(val levels: Int) {

    private var hasUndergroundLevels = false
    
    def this(levels: Int, hasUndergroundLevels: Boolean) {
        this(levels)
        this.hasUndergroundLevels = hasUndergroundLevels
    }
}

//now the class can be instantiated using an auxiliary constructor
val lift = new Lift(10, true)
{% endhighlight %}

"This is just like Java!"

In reality, this kind of constructors are not used that often. The main reason is because it's possible to define default values to constructor parameters. Furthermore, it's also possible to instantiate classes by passing their parameters by name:


{% highlight scala %}
class Lift(val levels: Int = 10, val hasUndergroundLevels: Boolean = false)

val defaultLift = new Lift
defaultLift.levels // Int = 10
defaultLeft.hasUndergroundLevels // Boolean = false

val customLift = new Lift(hasUndergroundLevels = true, levels = 3)
customLift.levels // Int = 3
customLift.hasUndergroundLevels // Boolean = true
{% endhighlight %}

# Objects

"Aha! I know this one. Objects are instances of those classes that you mentioned before!"

Well, that's indeed what an object is, but Scala has a reserved keyword and logic behind a construct that is also called *Object*. A Scala object defines a single instance of a class that encapsulates logic.

"Are you saying that is a singleton? But I read somewhere that singletons are a terrible thing that can come and eat you while you sleep!"

Truth is, that singletons are as bad as the usage that you make of them. If you're aware that a Scala object is a [singleton](https://en.wikipedia.org/wiki/Singleton_pattern) and use it as such, there should be nothing wrong with it. Going a bit further, Scala objects are a very helpful construct to define utility methods that do not require state to compute. A rather silly example, could be a CaseConverter object which operates on Strings:

{% highlight scala %}
object CaseConverter {

  def toPascalCase(input: String): String = input.split(" ").map(_.capitalize).mkString
  
  def toSnakeCase(input: String): String = input.split(" ").map(_.toLowerCase).mkString("_")
  
  def toCamelCase(input: String): String = {
  
    def lowerFirstChar(string: String): String = {
      string.head.toLower.toString + string.tail
    }
    
    lowerFirstChar(toPascalCase(input))
  }
}
{% endhighlight %}

This object can then be used without instantiating, pretty much like a static method:

{% highlight scala %}
CaseConverter.toPascalCase("my shiny variable")
res0: String = MyShinyVariable

CaseConverter.toSnakeCase("my shiny variable")
res1: String = my_shiny_variable

CaseConverter.toCamelCase("my shiny variable")
res2: String = myShinyVariable
{% endhighlight %}

Objects are very much like a Scala class but they do not receive constructor parameters. A typical use case for objects, is to provide static and instance methods to a class. This is known as acting as a *Companion Object*. For this to occur, both class and object should have the very same name and should live in the same file. Instance methods are achieved by implementing the *apply* method:

{% highlight scala %}
class Person(val name: String, val age: Int)

object Person {
  def apply(age: Int): Person = new Person("", age)
  def apply(name: String, age: Int): Person = new Person(name, age)
}
{% endhighlight %}

At a first glance, this might seem like an overkill and completely unnecessary. But actually, having objects acting as factories for creating instances of their accompanied classes can enhance Scala code readability a lot. 

{% highlight scala %}
val unknownPerson = Person(20)
val knownPerson = Person("Alan", 25)
{% endhighlight %}

"Wait! Where did the *new* keyword go?"
 
Companion objects have the capability of removing the need for the *new* keyword when instantiating the accompanied classes. This is pretty handy, specially when dealing with nested structures such as lists of lists:

{% highlight scala %}
val list = new List(new List(1), new List(2,5), new List(4,4))

vs

val list = List(List(1), List(2,5), List(4,4))
{% endhighlight %}

A final common use case for objects is to define a set of constants or enumerations. The easiest way to define them is by extending scala Enumeration:

{% highlight scala %}
object CardinalPoint extends Enumeration {

  type CardinalPoint = Value
  
  val North, South, West, East = Value
}
{% endhighlight %}

The type CardinalPoint is not actually necessary, but it's a good thing to add if type enforcing is needed in a function:
 
{% highlight scala %}
def move(towards: CardinalPoint): Position = ???

// This function can be called like so:
move(CardinalPoint.North)
{% endhighlight %}

It's also possible to give custom values to the elements of an enumeration. This way, the internal representation can be the one used by the algorithm but the code can read much better having meaningful names:

{% highlight scala %}
object CardinalPoint extends Enumeration {
  val North = "N"
  val South = "S"
  val West = "W"
  val East = "E"
}

...

val point = "N"
if (point == CardinalPoint.North) "I'm heading North!"
else "I'm lost :("

{% endhighlight %}

# Wrapping up

So hopefully this overview of classes and objects helps someone that is starting with Scala. There are a few more things that I could have mentioned about both classes and objects, but this overview was meant to cover just the basics and the most common use cases.

In the near future I'd like to continue this post by discussing *case classes*, which are one of the corner stones of the Scala language and are very much related to both classes and objects.
