/*
 * Copyright (c) 2005 Washington University in St. Louis.
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
 * - Neither the name of the copyright holders nor the names of
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
 */
 
/*
 * - Revision -------------------------------------------------------------
 * $Revision: 1.6 $
 * $Date: 2010/06/29 22:07:46 $ 
 * ======================================================================== 
 *
 */
 
 /**
 * Please refer to TEP 108 for more information about this interface and its
 * intended use.<br><br>
 * 
 * This interface is provided by a Resource arbiter in order to allow
 * users of a shared resource to configure that resource just before being
 * granted access to it.  It will always be parameterized along side 
 * a parameterized Resource interface, with the ids from one mapping directly
 * onto the ids of the other.
 *
 * @author Kevin Klues (klueska@cs.wustl.edu)
 */

interface ResourceConfigure {
  /**
   * Used to configure a resource just before being granted access to it.
   * Must always be used in conjuntion with the Resource interface.
   */
  async command void configure();

  /**
   * Used to unconfigure a resource just before releasing it.
   * Must always be used in conjuntion with the Resource interface.
   */
  async command void unconfigure();
} 
