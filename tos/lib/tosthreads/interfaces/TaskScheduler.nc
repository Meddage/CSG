// $Id: TaskScheduler.nc,v 1.2 2010/06/29 22:07:51 scipio Exp $
/*									tab:4
 * Copyright (c) 2004-5 The Regents of the University  of California.  
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * - Redistributions of source code must retain the above copyright
 *   notice, this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright
 *   notice, this list of conditions and the following disclaimer in the
 *   documentation and/or other materials provided with the
 *   distribution.
 * - Neither the name of the University of California nor the names of
 *   its contributors may be used to endorse or promote products derived
 *   from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL
 * THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * Copyright (c) 2004-5 Intel Corporation
 * All rights reserved.
 *
 * This file is distributed under the terms in the attached INTEL-LICENSE     
 * file. If you do not find these files, copies can be found by writing to
 * Intel Research Berkeley, 2150 Shattuck Avenue, Suite 1300, Berkeley, CA, 
 * 94704.  Attention:  Intel License Inquiry.
 */

/** 
  * The interface to a TinyOS task scheduler.
  *
  * @author Philip Levis
  * @author Kevin Klues <klueska@cs.stanford.edu>
  * @date   January 19 2005
  * @see TEP 106: Tasks and Schedulers
  * @see TEP 107: Boot Sequence
  */ 


interface TaskScheduler {

  /** 
   * Initialize the scheduler.
   */
  command void init();

  /** 
    * Run the next task if one is waiting, otherwise return immediately. 
    *
    * @return        whether a task was run -- TRUE indicates a task
    *                ran, FALSE indicates there was no task to run.
    */
  command bool runNextTask();
  
  /** 
    * Check to see if there are any pending tasks in the task queue. 
    *
    * @return        whether there are any tasks waiting to run
    */
  async command bool hasTasks();

  /**
   * Enter an infinite task-running loop. Put the MCU into a low power
   * state when the processor is idle (task queue empty, waiting for
   * interrupts). This call never returns.
   */
  command void taskLoop();
}

