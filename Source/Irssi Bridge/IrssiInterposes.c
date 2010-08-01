/*
 *  IrssiInterposes.c
 *  MacIrssi
 *
 *  Created by Matt Wright on 7/22/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#include "glib.h"

typedef struct interpose_s {
  void *new_func;
  void *old_func;
} interpose_t;

void _mi_source_add_poll(GSource *source, GPollFD *fd)
{
  abort();
}
#include <fcntl.h>
static const interpose_t interposers[] __attribute__((section("__DATA,__interpose"))) = {
  { (void*)_mi_source_add_poll, (void*)g_source_add_poll },
  { (void*)_mi_source_add_poll, (void*)open }
};