---
layout: post
title: Scala case classes
description: "Overview on what a case class is and what advantages introduces when programming in Scala"
category: blog
tags: [scala,case-class]
comments: true
image:
  feature: case-classes/case-classes.jpg
---

In my [previous post]({% post_url 2016-02-23-classes-and-objects %}) I made an overview to the relationship between classes and objects in Scala. In this post I'd like to review a language construct called `case class` which is basically a hyper dose of sugar on top of the other two.  

# What's a case class?

A case class is just a way to define a class which makes the compiler infer and create a bunch of information from its definition.

A very simple example could be something like this:

{% highlight scala %}
case class Person(name: String, surname: String, age: Int, sex: Gender)
{% endhighlight %}

This case class defines a series of attributes that are relevant to correctly represent a Person in our domain. But what's the benefit on doing it in such a way instead of just with the `class` construct? 

## Immutability using `val` as default

Defined properties are considered `val` unless stated otherwise with a `var`. This is due to scala favouring immutability whenever possible. Hence, all attributes come with a getter method for free.
  
{% highlight scala %}
scala> val matt = new Person("Matt", "White", 22, Gender.Male)

//We have getters defined for free
scala> matt.name
res0: String = Matt

//Setters are not present to favour immutability
scala> matt.name = "Matthew"
<console>:17: error: reassignment to val
       matt.name = "Matthew"
{% endhighlight %}

## Companion object with a default `apply` method

Another advantage from case classes is the fact that a hidden companion object comes also for free, avoiding the need for the `new` keyword when instantiating a new instance of the case class.

{% highlight scala %}
val matt = Person("Matt", "White", 22, Gender.Male)
{% endhighlight %}

This really helps to trim down code that creates new instances.

## Definition of `equals`, `hashCode`, `toString` and `copy`

For those of you that come from Java backgrounds, I'm sure you found yourself bored to death copy-pasting `hashCode` and `equals` methods for your custom classes. This is something that case classes take care for you as well, giving you default implementations for all these nice utility methods. Also for free!

### Equality

The equality comparison that the scala compiler provides on case classes is structural. This means that the equality won't be checking if both objects are effectively the same instance, but if their data are equivalent.

{% highlight scala %}
case class Circle(radius: Int)

val smallCircle = Circle(2)
val mediumCircle = Circle(5)
val anotherMediumCircle = Circle(5)

// These two instances are not equal
scala> smallCircle == mediumCircle
res4: Boolean = false

// These two instances are equal even though they are not the same instance
scala> mediumCircle == anotherMediumCircle 
res6: Boolean = true
{% endhighlight %}

### toString

When defining simple classes, Scala also provides an implementation of the `toString` method, but I think we can all agree that is not a very useful one.

{% highlight scala %}
scala> class Circle(radius: Int)
scala> val myCircle = new Circle(10)
scala> myCircle.toString
res0: Circle = Circle@8c3619e
{% endhighlight %}

Knowing the memory address in which the variable is stored is not telling us too much about the object, right?

A case class provides a more meaningful `toString` implementation, that provides information about the values that the class was constructed with.

{% highlight scala %}
scala> case class Circle(radius: Int)
scala> val bigCircle = Circle(10)
scala> bigCircle.toString
res0: Circle = Circle(10)

// Scala always tries running the toString method on an object expression
scala> bigCircle
res1: Circle = Circle(10)
{% endhighlight %}

### Copy

If you thought that the previous two convenience methods were useful, wait for this one. The `copy` method provides a mechanism to create a new instance of a case class, allowing to change any of its parameters by means of named parameters.

Let's see an example on our previous `Person` case class.

{% highlight scala %}
scala> val judith = Person("Judith", "Wytt", 22, Gender.Female)

// When judith turns 23, only her age representation would change
scala> val grownJudith = judith.copy(age = judith.age+1)
scala> grownJudith
res0: Person = Person(Judith,Wytt,23,Female)
{% endhighlight %}

This is quite awesome, isn't it?

## Extractors or `unapply`

This is probably the ultimate feature of case classes. Not because of the direct usage of this method, but more so in its usefulness for making pattern matching possible.
 
The `unapply` method is defined in the companion object of the case class and it basically works exactly in the opposite way of a constructor. Its signature looks like this:

{% highlight scala %}
def unapply(object: S): Option[T]
{% endhighlight %}

`T` here does not always comply to a single type. When a case class has more than one parameter in its definition, it becomes a tuple of its different types. For instance, the unnaply function for the following case classes would be:

{% highlight scala %}
//Single parameter
case class School(name: String)
object School {
    def unapply(school: School): Option[String] = Some(school.name)
}

//Multiple parameters
case class School(name: String, address: Address, yearOfConstruction: Int)
object School {
    def unapply(school: School): Option[(String, Address, Int)] = 
        Some(school.name, school.address, school.yearOfConstruction)
}
{% endhighlight %}

That's pretty much the boilerplate that the compiler writes for us, but why is this useful?

### Pattern Matching

If there's a functionality that heavily relies on extractors, that has to be pattern matching. Pattern matching is a technique that defines a list of possible values for a given variable to define specific behaviour based on that value. This is remarkably similar to a good old `switch` statement, but in reality is a bit more powerful than that. 

Case classes allow us to express our domains in something called `Algebraic Data Types (ADT)`. This is nothing else than a fancy name for a bunch of case classes or case objects that describe the different possible representations for a trait. For instance, in the context of an online marketing platform we could find the definition of what a contact might be:

{% highlight scala %}
sealed trait Contact
case class Email(address: EmailAddress) extends Contact
case class Phone(countryCode: CountryCode, number: PhoneNumber) extends Contact
case class Address(street: String, number: Int, postcode: Postcode, city: City, country: Country) extends Contact
{% endhighlight %}

Now imagine we've retrieved a customer's contact from a given source, and we want to create the appropriate message depending on the contact's type. Pattern matching to the rescue!

{% highlight scala %}
val message: Message = contact match {
    case Email(a) => buildEmail(a)
    case Phone(c,n) => buildSms(c,n)
    case Address(s,n,p,ci,co) => buildCard(s, n, p, ci, co)
)
{% endhighlight %}

Scala's pattern matching syntax comes into play after the `match` keyword. A list of expressions are listed using the `case` keyword (what a coincidence, right? ;) The `contact` variable is checked against this list and it applies the logic on the right hand side of the `=>` symbol on the first match. The way the list uses extractors could read as follows:
  
  - Is the contact an Email? If so, define `a` as the email address we built that Email case class with and run buildEmail with the email address `a` as its parameter.
  - Otherwise, is the contact a Phone? If so, define `c` and `n` as the country code and phone number we used to build the Phone case class and run buildSms with `c` and `n` as parameters.
  - Well, you get the gist ;)

Given we've defined our trait as `sealed` we know that this pattern matching is exhaustive and that we're covering all possible scenarios for a `Contact`.

# Wrapping up

In this post we've seen what a case class is and why it's useful. I'm still trying to understand how much logic should these classes contain or if they should aim to be as lean as possible. In future posts I'd like to discuss these dichotomies and share how I think these classes should be put to use in order to improve readability, maintainability and testability. 