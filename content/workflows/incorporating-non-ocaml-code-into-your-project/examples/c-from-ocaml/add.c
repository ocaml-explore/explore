#include <caml/mlvalues.h>

value add_c(value a, value b)
{
  return Val_long(Long_val(a) + (Long_val(b)));
}