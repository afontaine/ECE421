Questions
=========
1. What is a sparse matrix and what features should it possess?

   A sparse matrix is a matrix where most of the cells have the value 0. It 
   should support all the features a base matrix supports, but provide a
   much more effecient memory format. These features primarily include 3
   main categories: construction, enumerating/indexing, and arithmatic.

2. What sources of information should you consult to derive features? Do
   analogies exist? If so with what?

   We should consult Wikipedia and mathematicians on features that would be
   useful to implement. We can also consult other implementations for useful
   features to implement. We should understand Ruby's implementation of general
   matrices, and customize those features to our problem. Science python is a
   good implementation to consult for features to implement.

3. Who is likely to be the user of a sparse matrix package? What features are
   they likely to demand?

   Mathmeticians, engineers, staticians, accountants, sparse-matrix enthusiasts,
   and people that have to mark sparse matrices because it was an assignment.
   The bulk of the customers feature requests will focus around having the same
   features as a base matrix but improved space and arithmatic efficiency as the
   matrix becomes more and more sparse. Some of our customers will require obscure
   features like never using a loop, minimal use of temporary variables and
   conditionals. This small market will also be very focused on our library
   conforming to a well defined contract.

4. What is a tri-diagonal matrix?

   A tri-diagonal matrix is a matrix that only contains values on the main
   diagonal, the diagonal above the main diagonal, and the diagonal below the
   main diagonal.

5. What is the relationship between a tri-diagonal matrix and a generic sparse
   matrix?

   A sufficiently large tri-diagonal matrix is a sparse matrix with a predicable
    data layout.

6. Are tri-diagonal matrices important? And should they impact your design? If
   so, how?

   They are. They should. We can create a class specifically optimized for
   tri-diagonal matrices.

7. What is a good data representation for a sparse matrix?

   There are many data structure choices for sparse matrix. The simplest one
   would be a hash of hashes, with keys being the row and column index. This
   structure behaves very similarly to an array of arrays, making delegation
   to the base matrix class very simple. Another structure would be something
   like compressed row format. This format is great for arithmetic, but is
   very specialized and will severely limit our ability to delegate to the
   base matrix class.

8. Assume that you have a customer for your sparse matrix package. The customer
   states that their primary requirements as: for a N x N matrix with m non-zero
   entries Storage should be ~O(km), where k << N and m is any arbitrary type
   defined in your design. Adding the m+1 value into the matrix should have an
   execution time of ~O(p) where the execution time of all method calls in
   standard Ruby container classes is considered to have a unit value and p << m
   ideally p = 1 In this scenario, what is a good data representation for a
   sparse matrix?

   Since storage and insertion is the focus of performance a simple
   key-value-pair system like a Hash in Ruby would allow for minimal storage O(m),
   where m is number of non-zero elements and O(1) insertion. The key would be
   the serialized location (eg: "row,column") and the value would be the value of
   that location in the matrix. It would be simple to wrap this Hash in a custom
   class that takes in the row and column separately and serializes it into the
   appropriate key internally.

9. Design Patterns are common tricks which normally enshrine good practice.
   Explain the design patterns: Delegate and Abstract Factory Explain how you
   would approach implementing these two patterns in Ruby Are these patterns
   applicable to this problem? Explain your answer! (HINT: The answer is yes)

   Delegate Factory:
   Delegate factory is where the factories create methods are delegates that
   can be set at creation of the facotry or changed throughout the lifetime of
   the factory. This would be performed in ruby via assigning a code block
   (most likely a lambda function or a Proc) to some internal members of the
   factory. The process of assignment to the internal member is up to the
   implementation of the factory and could be through the initialize function,
   or through settings on the member.

   Abstract Factory:
   This pattern is where there is a base abstract factory that outlines a
   factory contract. There are then concrete factories that implement the
   contract laid out by the abstract factory. Each concrete factory may have
   different implementations, typically revolving around returning different
   subclasses of the class originally declared in the abstract factory. In
   Ruby this can be accomplished by having the AbstractFactory be a module that
   contains the contract as functions whose bodies all contain "raise
   NotImplementedException, 'Error Message'". The concrete factories would then
   include said module and re-implement all of its functions, but with actual
   implementations in the function bodies.

10. What implementation approach are you using (reuse class, modify class,
    inherit from class, compose with class, build new standalone class);
    justify your selection.

    We will be inheriting from the Matrix class as this will give us plenty
    of functionality for free. The caveat with this is that it will require
    us to use a sparse storage format very similar to an array of arrays
    so that the base matrix functions can access it like it normally does. To
    achieve this format we have chosen to also extend Hash as SparseHash and
    specialize this class to behave like an array (and an array of arrays) as
    much as possible. This will allow us to maximize our use of the base matrix
    class.

11. Is iteration a good technique for sparse matrix manipulation? Is “custom”
    iteration required for this problem?

    Iteration is always a good technique for data structure classes. Providing
    ways to iterate over the structure in various ways (such as only going over
    the non-zero values) can increase usability. Custom iteration was necessary
    on our extension of SparseHash so that it iterated like an array. 

12. What exceptions can occur during the processing of sparse matrices? And how
    should the system handle them?

13. What information does the system require to create a sparse matrix object?
    Remember you are building for a set of unknown customers – what will they want?

14. What are the important quality characteristics of a sparse matrix package?
    Reusability? Efficiency? Efficiency of what?

15. How do we generalize 2-D matrices to n-D matrices, where n > 2 – um, sounds
    like an extensible design?
