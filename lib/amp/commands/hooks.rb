##################################################################
#                  Licensing Information                         #
#                                                                #
#  The following code is licensed, as standalone code, under     #
#  the Ruby License, unless otherwise directed within the code.  #
#                                                                #
#  For information on the license of this code when distributed  #
#  with and used in conjunction with the other modules in the    #
#  Amp project, please see the root-level LICENSE file.          #
#                                                                #
#  © Michael J. Edgar and Ari Brown, 2009-2010                   #
#                                                                #
##################################################################

module Amp
  
  ##
  # = Hook
  # The hook class allows the end-user to easily provide hooks into the code that
  # makes Amp go. For example, one might want to easily hook into the commit command,
  # and send an e-mail out to your team after every commit. You could use the Hook class,
  # as well as the Kernel-level "hook" method, to do this.
  #
  # Hooks are global, currently - they cannot only be applied to one repo at a time.
  class Hook
    @@all_hooks = ArrayHash.new
    def self.all_hooks; @@all_hooks; end
    
    class << self
      
      raise "hell" if defined? DEFAULTS
      DEFAULTS = {:throw => false}
    
      ##
      # Call the hooks that run under +call+
      # 
      # @param [Symbol] call the location in the system where the hooks
      #   are to be called
      # @param [Hash] opts the options to pass to the hook
      def run_hook(call, opts={})
        opts = DEFAULTS.merge opts
        all_hooks[call].each {|hook| hook[opts] }
      end
    end
    
    ##
    # The call symbol this hook is associated with
    attr_accessor :name
    
    ##
    # The block to be executed when the hook is called
    attr_accessor :block
    
    ##
    # Registers a hook with the system. A hook is simply a proc that takes some
    # options. The hook has a name, which specifies which action it is hooking into.
    # Some hooks include:
    #   :outgoing
    #   :prechangegroup
    #   :changegroup
    #
    # @param [Symbol] hook_type the type of hook
    # @yield the given block is the action to take when the hook is executed
    # @yieldparam opts the options that are passed to the hook. See hook.rb for details
    #   on all possible hooks and their passed-in options.
    def initialize(name, &block)
      @name  = name
      @block = block
      @@all_hooks[name] << self
    end
    
    ##
    # Runs the hook.
    #
    # @param [Hash] opts the options to pass to the hook.
    def call(opts)
      @block.call(opts)
    end
    alias_method :run, :call
    alias_method :[],  :call
  end
end

module Kernel
  
  ##
  # Adds a hook to each of the provided hook entry points.
  # Requires a block.
  # 
  # @param [Symbol] names the hook entry points for which to add the block as a hook
  # @yield The block provided is the code that will be run as a hook at a later time.
  def hook(names, &block)
    Amp::Hook.new(names, &block)
  end
end
