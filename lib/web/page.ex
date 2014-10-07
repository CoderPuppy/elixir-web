defmodule Web.Page do
	defmacro __using__(opts) do
		IO.inspect({ __MODULE__, opts })
		quote do: nil
	end
end