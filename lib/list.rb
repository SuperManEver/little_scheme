require 'lambda'

class List
  def initialize(*array)
    @array = array
  end

  def evaluate(env)
    function, *arguments = array
    if function.is_a? List
      parameters = function.cdr.car.array
      expression = function.cdr.cdr.car

      Lambda.new(parameters, expression).evaluate(env, arguments)
    else
      operation = function.symbol
      if env.key?(operation)
        env[operation].evaluate(env, arguments)
      else
        case operation
        when :lambda
          parameters = arguments.first.array
          expression = arguments.last

          Lambda.new(parameters, expression)
        when :quote
          arguments.first
        when :cond
          arguments.detect { |list| list.car.evaluate(env) == Atom::TRUE }.cdr.car.evaluate(env)
        when :or
          arguments.first.evaluate(env) == Atom::TRUE ? Atom::TRUE : arguments.last.evaluate(env)
        else
          first_argument, *other_arguments = arguments.map { |a| a.evaluate(env) }
          first_argument.send(operation, *other_arguments)
        end
      end
    end
  end

  def car
    raise if @array.empty?
    @array.first
  end

  def cdr
    raise if @array.empty?
    self.class.new(*@array[1..-1])
  end

  def cons(list)
    list.prepend(self)
  end

  def prepend(sexp)
    List.new(sexp, *array)
  end

  def null?
    array.empty? ? Atom::TRUE : Atom::FALSE
  end

  def atom?
    Atom::FALSE
  end

  def ==(other)
    self.array == other.array
  end

  def inspect
    "(#{@array.map(&:inspect).join(' ')})"
  end

  attr_reader :array
end