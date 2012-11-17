require 'spec_helper'

describe :@symbolize do
  it :@symbolize_a_string do
    "My Symbol".symbolize.should eq :my_symbol
    "MySymbol".symbolize.should eq :my_symbol
  end

  it :@symbolize_a_symbol do
    :MySymbol.symbolize.should eq :my_symbol
    :My_Symbol.symbolize.should eq :my_symbol
    :"My symbol".symbolize.should eq :my_symbol
  end

  it :@symbolize_a_nil do
    nil.symbolize.should eq :nil
  end

end