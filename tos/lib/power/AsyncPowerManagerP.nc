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
 *
 */
 
/*
 * - Revision -------------------------------------------------------------
 * $Revision: 1.7 $
 * $Date: 2010/06/29 22:07:50 $ 
 * ======================================================================== 
 */
 
/**
 * Please refer to TEP 115 for more information about this component and its
 * intended use.<br><br>
 *
 * This is the internal implementation of the standard power management
 * policy for managing the power states of non-virtualized devices.
 * Non-virtualized devices are shared using a parameterized Resource
 * interface, and are powered down according to some policy whenever there
 * are no more pending requests to that Resource.  The policy implemented
 * by this component is to power down a device as soon as it becomes free.
 * Such a policy is useful whenever a device has a negligible wake-up
 * latency.  There is no cost associated with waiting for the device to
 * power up, so it can be powered on and off as often as possible.
 * 
 * @author Kevin Klues (klueska@cs.wustl.edu)
 */
 
generic module AsyncPowerManagerP() @safe() {
  uses {
    interface AsyncStdControl;

    interface PowerDownCleanup;
    interface ResourceDefaultOwner;
    interface ArbiterInfo;
  }
}
implementation {

  async event void ResourceDefaultOwner.requested() {
    call AsyncStdControl.start();
    call ResourceDefaultOwner.release(); 
  }

  async event void ResourceDefaultOwner.immediateRequested() {
    call AsyncStdControl.start();
    call ResourceDefaultOwner.release();
  } 

  async event void ResourceDefaultOwner.granted() {
    call PowerDownCleanup.cleanup();
    call AsyncStdControl.stop();
  }

  default async command void PowerDownCleanup.cleanup() {
  }
}
