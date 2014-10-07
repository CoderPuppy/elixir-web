require Web
defmodule MovieVoting do
	defmodule VotePage do
		use Web.Page

		defmodule State do
			defstruct user: nil
		end

		def init, do: %State{}

		def handle(state, event) do
			IO.inspect(event)
			state
		end

		defmodule HTMLView do
			use Web.View, for: VotePage, format: Web.HTML
			
			def render(state) do
				"selected user: #{state.user}"
			end
		end
	end

	defmodule API do
		use Web.API
	end
end