defmodule Web.HTML do
	use Web.Format

	defmacro __using__(opts) do
		IO.inspect({ __MODULE__, opts })
		quote do
			import unquote(__MODULE__), only: [h: 1, h: 2, h: 3]
		end
	end

	defmodule Element do
		defstruct tagname: :div, attrs: %{}, content: []
		@type t :: %Element{tagname: atom, attrs: Map.t, content: List.t}
	end
	alias Element, as: Elem

	defimpl Web.Format.Node, for: Element do
		def type(elem), do: elem.tagname
		def attrs(elem), do: elem.attrs
		def set_attrs(elem, attrs) when is_map(attrs), do: %{ elem | attrs: attrs}
	end
	defimpl Web.Format.ParentNode, for: Element do
		def children(elem), do: elem.content
		def add_child(elem, child), do: %{ elem | content: elem.content ++ unify_content(child) }
		def remove_child(elem, child), do: %{ elem | content: List.delete(elem.content, child) }
	end

	defmodule TextNode do
		defstruct content: ""
		@type t :: %TextNode{ content: String.t }
	end

	defimpl Web.Format.Node, for: TextNode do
		def type(_node), do: "<text>"
		def attrs(node), do: %{ content: node.content }
		def set_attrs(node, attrs) do
			if is_bitstring(attrs[:content]) or is_binary(attrs[:content]) do
				%{ node | content: attrs[:content] }
			else
				node
			end
		end
	end

	defmodule CommentNode do
		defstruct content: ""
		@type t :: %CommentNode{content: String.t}
	end

	defimpl Web.Format.Node, for: CommentNode do
		def type(_node), do: "<comment>"
		def attrs(node), do: %{ content: node.content }
		def set_attrs(node, attrs) do
			if is_bitstring(attrs[:content]) or is_binary(attrs[:content]) do
				%{ node | content: attrs[:content] }
			else
				node
			end
		end
	end

	def h(tagname, attrs \\ %{}, [do: content] \\ [do: nil]) do
		has_body = Enum.any?(attrs, fn {name, _val} -> name == :do end)
		if has_body do
			content = attrs[:do]
			attrs = %{}
		end
		%Elem{ tagname: unify_tagname(tagname), attrs: unify_attrs(attrs), content: unify_content(content) }
	end

	defp unify_content(content) when is_list(content) do
		content
			|> Enum.map(&unify_content/1)
			|> List.flatten
	end
	defp unify_content(content) when is_binary(content) or is_bitstring(content), do: [ %TextNode{content: content} ]
	defp unify_content(content = %Element{}), do: content
	defp unify_content(content = %TextNode{}), do: content
	defp unify_content(content = %CommentNode{}), do: content

	defp unify_attrs(attrs) when is_list(attrs) do
		if Keyword.keyword?(attrs) do
			attrs
				|> Enum.reduce(%{}, fn { key, val }, acc ->
					Dict.put(acc, key, val)
				end)
		else
			%{}
		end
	end
	defp unify_attrs(attrs) when is_map(attrs) do
		attrs
	end

	defp unify_tagname(tagname) when is_binary(tagname) or is_bitstring(tagname) do
		String.to_atom(tagname)
	end
	defp unify_tagname(tagname) when is_atom(tagname) do
		tagname
	end
end