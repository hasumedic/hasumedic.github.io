---
layout: post
title: Sliding through collections
description: "A rather useful little function to slide through Scala collections with ease"
category: blog
comments: true
tags: [scala, collections, sliding]
image:
  feature: "collections-sliding/collections-sliding.jpg"
---

The other day I found myself trying to solve one of those math puzzles which had to do with doing computations on subsets of a very large number to then obtain a final result. Something along the lines of:

"Given the string representing the number 127361827391827309127381263, what would be the biggest product of its internal consecutive numbers grouped by 5?"
 
So I jumped straight into implementing a function that, using an accumulator recursively, would come up with a list containing all the subset combinations:
   
{% highlight scala %}
def slices(size: Int, digits: String): List[List[Char]] = {
  
  def sliceAcc(size: Int, digits: String, acc: List[List[Char]]): List[List[Char]] = {
    if (digits.length < size) acc
    else sliceAcc(size, digits.drop(1), acc ++ List(digits.take(size).toList))
  }

  sliceAcc(size, digits, Nil)
}

scala> slices(2, "1234567890")
res0: List[List[Char]] = List(List(1, 2), List(2, 3), List(3, 4), List(4, 5), List(5, 6), List(6, 7), List(7, 8), List(8, 9), List(9, 0))

{% endhighlight %}
   
Although this works, it looks a bit messy. It's not just the fact of using an accumulator, but also the reduction of the input is not clear enough.

Luckily, later I found a way to do exactly this which was already built in in the Scala collections!

# Sliding

The "sliding" function is defined by the Scala's Iterator trait like so:

{% highlight scala %}
def sliding[B >: A](size: Int, step: Int = 1): GroupedIterator[B]
{% endhighlight %}

Its signature indicates that a GroupedIterator is returned. GroupIterator differs from Iterator (amongst other things) by defining a strategy for dealing with elements which do not evenly fit in grouping operations such as "sliding". We'll see an example in a bit.

So by using "sliding", the whole of my "slices" function could have been achieved with a simple one-liner:

{% highlight scala %}
"1234567890".toList.sliding(2).toList
res1: List[List[Char]] = List(List(1, 2), List(2, 3), List(3, 4), List(4, 5), List(5, 6), List(6, 7), List(7, 8), List(8, 9), List(9, 0))
{% endhighlight %}

The second parameter of "sliding" allows us to define a jump between where the previous partition was made before start grouping again.

{% highlight scala %}
"1234567890".toList.sliding(3, 2).toList
res2: List[List[Char]] = List(List(1, 2, 3), List(3, 4, 5), List(5, 6, 7), List(7, 8, 9), List(9, 0))
{% endhighlight %}

Notice that in here we get 4 groups of 3 and a single group with 2 elements. Depending on the use case, this behaviour might not be desired. What we might need instead, are those values that form a complete group. Here's where the strategy defined in the GroupedIterator comes into play. It provides a method **withPartials()** which accepts a boolean to indicate whether we want to discard partial results.

{% highlight scala %}
"1234567890".iterator.sliding(3, 2).withPartial(false).toList
res3: List[Seq[Char]] = List(List(1, 2, 3), List(3, 4, 5), List(5, 6, 7), List(7, 8, 9))
{% endhighlight %}

Finally, calling "sliding" with the same value in both parameters is equivalent to using the function "grouped".

{% highlight scala %}
"1234567890".toList.sliding(2, 2).toList
res4: List[List[Char]] = List(List(1, 2), List(3, 4), List(5, 6), List(7, 8), List(9, 0))

"1234567890".toList.grouped(2).toList
res5: List[List[Char]] = List(List(1, 2), List(3, 4), List(5, 6), List(7, 8), List(9, 0))
{% endhighlight %}

# Use cases

I find this method very useful to help finding solutions to mathematical problems like the one described at the beginning of the post. 

Considering the problem again: "Given the string representing the number 127361827391827309127381263, what would be the biggest product of its internal consecutive numbers grouped by 5?"

What we are really looking for is 127361**82739**1827309127381263, its product yielding a result of 3024.

{% highlight scala %}
"127361827391827309127381263".map(_.asDigit).sliding(5).map(_.product).max
res6: Int = 3024
{% endhighlight %}

So we have just transformed the input into digits, created the groups of 5 with "sliding", mapped over the groups applying the product of its numbers and finally picking its maximum value. Neat!

But can we also use this function in something closer to a real world scenario? 

Well, lets imagine an overly-simplified example on a city-break quoting system. We want to allow our customers to find out what is the cheapest price to travel to a destination for a certain amount of days on any day for the following month.

The system would have a service to obtain the best price for a destination based on a list of consecutive days:

{% highlight scala %}
    def price(destination: Destination, travelDates: Seq[DateTime]): Money
{% endhighlight %}

The only thing we need, is call this service for all possible dates within the next month. And we can do that by using "sliding":

{% highlight scala %} 
val nextMonthDays:Iterator[DateTime] = Iterator.iterate(new DateTime())(_ plusDays 1) takeWhile (_ isBefore new DateTime().plusMonths(1))

def findBestPriceForNextMonth(destination: Destination, numberOfDays: Int): Money = {
  val possibleDates = nextMonthDays.sliding(numberOfDays)
  possibleDates.map(days => price(destination, days)).min
}

findBestPriceForNextMonth("Barcelona", 4)
{% endhighlight %}

In this particular example, we would find the cheapest price to go to Barcelona for 4 days during the next month.



Header Image: [Matteo Dunchi via Flickr](https://www.flickr.com/photos/md88/11928135214/)