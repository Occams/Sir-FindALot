module PagesHelper
  def faq(id, question, &block)
    tag :div, :class => "faq", :id => id do
      content_tag :div, question, :class => "question"
      content_tag :div, :class => "answer", &block
    end
  end
end
