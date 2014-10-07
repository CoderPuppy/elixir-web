defmodule Web.View do
	defmacro __using__(opts) do
		IO.inspect { __MODULE__, opts }
		quote do
			use unquote(opts[:format])
			@format unquote(opts[:format])
		end
	end
end