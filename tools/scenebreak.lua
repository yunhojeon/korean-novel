--[[
scenebreak – convert raw LaTeX page breaks to other formats

Copyright © 2017-2019 Benct Philip Jonsson, Albert Krewinkel

Permission to use, copy, modify, and/or distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
]]
local stringify_orig = (require 'pandoc.utils').stringify

local function stringify(x)
  return type(x) == 'string' and x or stringify_orig(x)
end


-- scene break mark: centered "* * *" with blank lines above and below
local scenebreak = {
  epub = '<p>&nbsp;</p><p style="text-align:center;">* * *</p><p>&nbsp;</p>',
  html = '<p>&nbsp;</p><div style="text-align:center;">* * *</div><p>&nbsp;</p>',
  latex = '\\begin{center} \\bigbreak * * * \\bigbreak  \\end{center}',
  ooxml = '<w:p/><w:p><w:pPr><w:jc w:val="center"/></w:pPr><w:r><w:t>* * *</w:t></w:r></w:p><w:p/>',
}

-- line break (one blank line)
local linebreak = {
  -- epub = '<p style="text-align:center;">&nbsp;</p>',
  -- html = '<div style="text-align:center;">&nbsp</div>',
  epub = '<p>&nbsp;</p>',
  html = '<p>&nbsp;</p>',
  latex = '\\bigbreak',
  ooxml = '<w:p/>',
}

--- Return a block element causing a page break in the given format.
local function newscene(format)
  if format == 'docx' then
    return pandoc.RawBlock('openxml', scenebreak.ooxml)
  elseif format:match 'latex' then
    return pandoc.RawBlock('tex', scenebreak.latex)
  elseif format:match 'odt' then
    return pandoc.RawBlock('opendocument', scenebreak.odt)
  elseif format:match 'html.*' then
    return pandoc.RawBlock('html', scenebreak.html)
  elseif format:match 'epub' then
    return pandoc.RawBlock('html', scenebreak.epub)
  else
    -- fall back to insert a form feed character
    return pandoc.Para{pandoc.Str '\f'}
  end
end

local function newline(format)
  if format == 'docx' then
    return pandoc.RawBlock('openxml', linebreak.ooxml)
  elseif format:match 'latex' then
    return pandoc.RawBlock('tex', linebreak.latex)
  elseif format:match 'odt' then
    return pandoc.RawBlock('opendocument', linebreak.odt)
  elseif format:match 'html.*' then
    return pandoc.RawBlock('html', linebreak.html)
  elseif format:match 'epub' then
    return pandoc.RawBlock('html', linebreak.epub)
  else
    -- fall back to insert a form feed character
    return pandoc.Para{pandoc.Str '\f'}
  end
end

local function is_scenebreak_command(command)
  return command:match '^\\scenebreak%{?%}?$'
    or command:match '^\\newscene%{?%}?$'
end

local function is_linebreak_command(command)
  return command:match '^\\n$'
end

-- Filter function called on each RawBlock element.
function RawBlock (el)
  -- Don't do anything if the output is TeX
  -- if FORMAT:match 'tex$' then
  --   return nil
  -- end
  -- check that the block is TeX or LaTeX and contains only
  -- \newpage or \pagebreak.
  if el.format:match 'tex' then
    if is_scenebreak_command(el.text) then
    -- use format-specific pagebreak marker. FORMAT is set by pandoc to
    -- the targeted output format.
      return newscene(FORMAT)
    elseif is_linebreak_command(el.text) then
      return newline(FORMAT)
    end
  end
  -- otherwise, leave the block unchanged
  return nil
end

-- Turning paragraphs which contain nothing but a form feed
-- characters into line breaks.
function Para (el)
  if #el.content == 1 and el.content[1].text == '\f' then
    return newscene(FORMAT)
  end
end

return {
  {Meta = scenebreaks_from_config},
  {RawBlock = RawBlock, Para = Para}
}
