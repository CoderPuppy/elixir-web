defmodule Web.Format do
	defmacro __using__(opts) do
		IO.inspect { __MODULE__, opts }
		quote do: nil
	end

	defprotocol Node do
		def type(node)

		def attrs(node)
		def set_attrs(node, attrs)
	end

	defprotocol ParentNode do
		def children(node)
		def add_child(node, child, before \\ nil)
		def remove_child(node, child)
	end
end