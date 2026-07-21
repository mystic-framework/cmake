# -------------------------------------------------------------------------------------------------
# File: mystic_ascii_banner.cmake
# Desc: Generates a Shadow ASCII art for banner.
# Auth: thedevmystic (Surya) <thedevmystic@gmail.com>
# Licence: Apache 2.0 License
# -------------------------------------------------------------------------------------------------
# Usage:
# include(path/to/mystic_ascii_banner)
# mystic_ascii_banner("YOUR TEXT HERE")
# -------------------------------------------------------------------------------------------------

# -------------------------------------------------------------------------------------------------
# Shadow ASCII art letters
# -------------------------------------------------------------------------------------------------
list(APPEND ASCII_FONT_A " █████╗ " "██╔══██╗" "███████║" "██╔══██║" "██║  ██║" "╚═╝  ╚═╝")
list(APPEND ASCII_FONT_B "██████╗ " "██╔══██╗" "██████╔╝" "██╔══██╗" "██████╔╝" "╚═════╝ ")
list(APPEND ASCII_FONT_C " ██████╗" "██╔════╝" "██║     " "██║     " "╚██████╗" " ╚═════╝")
list(APPEND ASCII_FONT_D "██████╗ " "██╔══██╗" "██║  ██║" "██║  ██║" "██████╔╝" "╚═════╝ ")
list(APPEND ASCII_FONT_E "███████╗" "██╔════╝" "█████╗  " "██╔══╝  " "███████╗" "╚══════╝")
list(APPEND ASCII_FONT_F "███████╗" "██╔════╝" "█████╗  " "██╔══╝  " "██║     " "╚═╝     ")
list(APPEND ASCII_FONT_G " ██████╗ " "██╔════╝ " "██║  ███╗" "██║   ██║" "╚██████╔╝" " ╚═════╝ ")
list(APPEND ASCII_FONT_H "██╗  ██╗" "██║  ██║" "███████║" "██╔══██║" "██║  ██║" "╚═╝  ╚═╝")
list(APPEND ASCII_FONT_I "██╗" "██║" "██║" "██║" "██║" "╚═╝")
list(APPEND ASCII_FONT_J "     ██╗" "     ██║" "     ██║" "██   ██║" "╚█████╔╝" " ╚════╝ ")
list(APPEND ASCII_FONT_K "██╗  ██╗" "██║ ██╔╝" "█████═╝ " "██╔═██╗ " "██║  ██╗" "╚═╝  ╚═╝")
list(APPEND ASCII_FONT_L "██╗     " "██║     " "██║     " "██║     " "███████╗" "╚══════╝")
list(APPEND ASCII_FONT_M "███╗   ███╗" "████╗ ████║" "██╔████╔██║" "██║╚██╔╝██║" "██║ ╚═╝ ██║" "╚═╝     ╚═╝")
list(APPEND ASCII_FONT_N "███╗   ██╗" "████╗  ██║" "██╔██╗ ██║" "██║╚██╗██║" "██║ ╚████║" "╚═╝  ╚═══╝")
list(APPEND ASCII_FONT_O " ██████╗ " "██╔═══██╗" "██║   ██║" "██║   ██║" "╚██████╔╝" " ╚═════╝ ")
list(APPEND ASCII_FONT_P "██████╗ " "██╔══██╗" "██████╔╝" "██╔═══╝ " "██║     " "╚═╝     ")
list(APPEND ASCII_FONT_Q " ██████╗ " "██╔═══██╗" "██║   ██║" "██║▄▄ ██║" "╚██████╔╝" " ╚══▀▀═╝ ")
list(APPEND ASCII_FONT_R "██████╗ " "██╔══██╗" "██████╔╝" "██╔══██╗" "██║  ██║" "╚═╝  ╚═╝")
list(APPEND ASCII_FONT_S "███████╗" "██╔════╝" "███████╗" "╚════██║" "███████║" "╚══════╝")
list(APPEND ASCII_FONT_T "████████╗" "╚══██╔══╝" "   ██║   " "   ██║   " "   ██║   " "   ╚═╝   ")
list(APPEND ASCII_FONT_U "██╗   ██╗" "██║   ██║" "██║   ██║" "██║   ██║" "╚██████╔╝" " ╚═════╝ ")
list(APPEND ASCII_FONT_V "██╗   ██╗" "██║   ██║" "██║   ██║" "╚██╗ ██╔╝" " ╚████╔╝ " "  ╚═══╝  ")
list(APPEND ASCII_FONT_W "██╗    ██╗" "██║    ██║" "██║ █╗ ██║" "██║███╗██║" "╚███╔███╔╝" " ╚══╝╚══╝ ")
list(APPEND ASCII_FONT_X "██╗  ██╗" "╚██╗██╔╝" " ╚███╔╝ " " ██╔██╗ " "██╔╝ ██╗" "╚═╝  ╚═╝")
list(APPEND ASCII_FONT_Y "██╗   ██╗" "╚██╗ ██╔╝" " ╚████╔╝ " "  ╚██╔╝  " "   ██║   " "   ╚═╝   ")
list(APPEND ASCII_FONT_Z "███████╗" "╚══███╔╝" "  ███╔╝ " " ███╔╝  " "███████╗" "╚══════╝")
list(APPEND ASCII_FONT_0 " ██████╗ " "██╔═████╗" "██║██╔██║" "████╔╝██║" "╚██████╔╝" " ╚═════╝ ")
list(APPEND ASCII_FONT_1 " ██╗" "███║" "╚██║" " ██║" " ██║" " ╚═╝")
list(APPEND ASCII_FONT_2 "██████╗ " "╚════██╗" " █████╔╝" "██╔═══╝ " "███████╗" "╚══════╝")
list(APPEND ASCII_FONT_3 "██████╗ " "╚════██╗" " █████╔╝" " ╚═══██╗" "██████╔╝" "╚═════╝ ")
list(APPEND ASCII_FONT_4 "██╗  ██╗" "██║  ██║" "███████║" "╚════██║" "     ██║" "     ╚═╝")
list(APPEND ASCII_FONT_5 "███████╗" "██╔════╝" "███████╗" "╚════██║" "███████║" "╚══════╝")
list(APPEND ASCII_FONT_6 " ██████╗" "██╔════╝" "███████╗" "██╔═══██╗" "╚██████╔╝" " ╚═════╝ ")
list(APPEND ASCII_FONT_7 "███████╗" "╚════██║" "    ██╔╝" "  ██╔╝ " "  ██║  " "  ╚═╝  ")
list(APPEND ASCII_FONT_8 " █████╗ " "██╔══██╗" "╚█████╔╝" "██╔══██╗" "╚█████╔╝" " ╚════╝ ")
list(APPEND ASCII_FONT_9 " █████╗ " "██╔══██╗" "╚██████║" " ╚═══██║" " █████╔╝" " ╚════╝ ")

# -------------------------------------------------------------------------------------------------
# Desc: Function to generate ASCII art for a given input string.
# Note: This supports A-Z, 0-9, and space characters.
# Args:
#   INPUT_STRING: The string to be converted into ASCII art.
# -------------------------------------------------------------------------------------------------
function(mystic_ascii_banner INPUT_STRING)
  # Split space-separated input string into individual word tokens
  string(REPLACE " " ";" WORDS "${INPUT_STRING}")

  foreach(WORD IN LISTS WORDS)
    string(TOUPPER "${WORD}" WORD_UPPER)
    string(LENGTH "${WORD_UPPER}" WORD_LEN)
    
    if(WORD_LEN EQUAL 0)
      continue()
    endif()

    set(LINE_0 "")
    set(LINE_1 "")
    set(LINE_2 "")
    set(LINE_3 "")
    set(LINE_4 "")
    set(LINE_5 "")

    math(EXPR MAX_IDX "${WORD_LEN} - 1")
    foreach(I RANGE ${MAX_IDX})
      string(SUBSTRING "${WORD_UPPER}" ${I} 1 CHAR)
      
      if(DEFINED ASCII_FONT_${CHAR})
        list(GET ASCII_FONT_${CHAR} 0 C0)
        list(GET ASCII_FONT_${CHAR} 1 C1)
        list(GET ASCII_FONT_${CHAR} 2 C2)
        list(GET ASCII_FONT_${CHAR} 3 C3)
        list(GET ASCII_FONT_${CHAR} 4 C4)
        list(GET ASCII_FONT_${CHAR} 5 C5)

        string(APPEND LINE_0 "${C0} ")
        string(APPEND LINE_1 "${C1} ")
        string(APPEND LINE_2 "${C2} ")
        string(APPEND LINE_3 "${C3} ")
        string(APPEND LINE_4 "${C4} ")
        string(APPEND LINE_5 "${C5} ")
      endif()
    endforeach()

    # Output the word block
    message(NOTICE "${LINE_0}")
    message(NOTICE "${LINE_1}")
    message(NOTICE "${LINE_2}")
    message(NOTICE "${LINE_3}")
    message(NOTICE "${LINE_4}")
    message(NOTICE "${LINE_5}")
    message(NOTICE "") # Line break between words
  endforeach()
endfunction()
