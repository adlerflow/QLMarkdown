//
//  extra-extensions.c
//  TextDown
//
//  Created by adlerflow on 14/04/23.
//

#include "extra-extensions.h"

#include "cmark-gfm-core-extensions.h"
#include "registry.h"
#include "plugin.h"

#include "mention.h"
// #include "checkbox.h"
#include "inlineimage.h"
#include "emoji.h"
#include "heads.h"
#include "highlight.h"
#include "math_ext.h"
#include "sub_ext.h"
#include "sup_ext.h"

static int extra_extensions_registration(cmark_plugin *plugin) {
    cmark_plugin_register_syntax_extension(plugin, create_mention_extension());
    //cmark_plugin_register_syntax_extension(plugin, create_checkbox_extension());
    cmark_plugin_register_syntax_extension(plugin, create_inlineimage_extension());

    cmark_plugin_register_syntax_extension(plugin, create_emoji_extension());
    cmark_plugin_register_syntax_extension(plugin, create_heads_extension());
    cmark_plugin_register_syntax_extension(plugin, create_highlight_extension());
    cmark_plugin_register_syntax_extension(plugin, create_math_extension());
    cmark_plugin_register_syntax_extension(plugin, create_sup_extension());
    cmark_plugin_register_syntax_extension(plugin, create_sub_extension());
    return 1;
}

void cmark_gfm_extra_extensions_ensure_registered(void) {
  static int registered = 0;

  if (!registered) {
    cmark_register_plugin(extra_extensions_registration);
    registered = 1;
  }
}
