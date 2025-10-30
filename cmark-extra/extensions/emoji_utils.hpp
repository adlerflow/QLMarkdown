//
//  emoji_utils.hpp
//  TextDown
//
//  Created by adlerflow on 23/12/20.
//

#ifndef emoji_utils_hpp
#define emoji_utils_hpp

#ifdef __cplusplus
extern "C" {
#endif

/**
  * Get the image url for a emoji placeholder.
  * @param placeholder Emoji placeholder.
  * @return The image url or NULL if the placeholder is invalid. 
 */
const char *get_emoji_url(const char *placeholder);

/**
  * Get the glyphs for a emoji placeholder.
  * @param placeholder Emoji placeholder.
  * @return The image glyphs or NULL if the placeholder is invalid or do not exists a glyphs.
 */
const char *get_emoji_glyphs(const char *placeholder);

// /**
//   * Get the emoji for a placeholder.
//   * @param placeholder Emoji placeholder.
//   * @return The emoji string or NULL if the placeholder is invalid. **User must release the memory.**
//  */
// char *get_emoji(const char *placeholder);

#ifdef __cplusplus
}
#endif
#endif /* emoji_utils_hpp */
