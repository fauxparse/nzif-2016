module RollsHelper
  def fullness_graph(count, limit, options = {})
    options = options.reverse_merge(
      :xmlns      => 'http://www.w3.org/2000/svg',
      :'xml:lang' => 'en',
      :width      => 160,
      :height     => 160,
      :class      => 'graph',
      :text       => true
    )

    width = options[:width]
    height = options[:height]
    cx = width / 2
    cy = height / 2
    options[:viewbox] = "0 0 #{width} #{height}"

    content_tag :svg, options do
      concat svg_circle(cx, cy, cx - 10)
      concat svg_circular_path(cx, cy, cx - 10, count * 1.0 / (limit || count))
      if options[:text]
        if limit
          concat svg_text(cx, cy, count, class: "count")
          concat svg_text(cx, cy + 24, "of #{limit}", class: "limit")
        else
          concat svg_text(cx, cy + 14, count, class: "count")
        end
      end
    end
  end

  private

  def svg_circle(cx, cy, r)
    content_tag :circle, nil, cx: cx, cy: cy, r: r
  end

  def svg_circular_path(cx, cy, r, fraction = 1)
    path_length = Math::PI * 2 * r
    content_tag :path, nil,
      d: "M #{cx} #{cy-r} A #{r} #{r} 0 1 1 #{cx} #{cy+r} A #{r} #{r} 0 1 1 #{cx} #{cy - r}",
      style: "stroke-dasharray: #{path_length}; stroke-dashoffset: #{path_length * (1.0 - fraction)}"
  end

  def svg_text(x, y, text, options = {})
    content_tag :text, text, options.reverse_merge(x: x, y: y)
  end
end
