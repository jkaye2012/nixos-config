{ config, pkgs, ... }:

{
  imports = [
    /etc/nixos/hardware-configuration.nix
  ];

  system.stateVersion = "24.05";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # You should only edit the lines below if you know what you are doing.

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";

  environment.systemPackages = with pkgs; [
    git
    (builtins.getFlake "/home/jkaye/git/neovim-flake").packages.x86_64-linux.jkvim
  ];

  fonts.packages = with pkgs; [
    fira-code
    fira-code-symbols
  ];

  nix.extraOptions = ''
    bash-prompt-prefix = \[\033[1;30m\](nix:$name)\040
  '';

  programs.bash.promptInit = ''
    if [ "$TERM" != "dumb" ] || [ -n "$INSIDE_EMACS" ]; then
      PROMPT_COLOR="1;31m"
      ((UID)) && PROMPT_COLOR="1;32m"
      if [ -n "$INSIDE_EMACS" ]; then
        # Emacs term mode doesn't support xterm title escape sequence (\e]0;)
        PS1="\[\033[$PROMPT_COLOR\][\u@\h:\w]\\$\[\033[0m\] "
      else
        PS1="\[\033[$PROMPT_COLOR\][\[\e]0;\u@\h: \w\a\]\u@\h:\w]\\$\[\033[0m\] "
      fi
      if test "$TERM" = "xterm"; then
        PS1="\[\033]2;\h:\u:\w\007\]$PS1"
      fi
    fi
  '';

  programs.direnv.enable = true;

  # This is the server's hostname you chose during the order process. Feel free to change it.

  networking.hostName = "jkaye-nixos";

  # We use the dhcpcd daemon to automatically configure your network. For IPv6 we need to make sure
  # that no temporary addresses (or privacy extensions) are used. Your server is required to use the
  # network data that is displayed in the Network tab in our client portal, otherwise your server will
  # loose internet access due to network filters that are in place.

  networking.dhcpcd.IPv6rs = true;
  networking.dhcpcd.persistent = true;
  networking.tempAddresses = "disabled";
  networking.interfaces.ens3.tempAddress = "disabled";

  # To allow you to properly use and access your VPS via SSH, we enable the OpenSSH server and
  # grant you root access. This is just our default configuration, you are free to remove root
  # access, create your own users and further secure your server.

  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "no";
  services.openssh.settings.PasswordAuthentication = false;
  networking.firewall.allowedTCPPorts = [ 22 ];

  # Under normal circumstances we would listen to your server's cloud-init callback and mark the server
  # as installed at this point. As we don't deliver cloud-init with NixOS we have to use a workaround
  # to indicate that your server is successfully installed. You can remove the cronjob after the server
  # has been started the first time. It's no longer needed.

  services.cron.enable = true;
  services.cron.systemCronJobs = [
    "@reboot root sleep 30 && curl -L -XPOST -q https://portal.vps2day.com/api/service/v1/cloud-init/callback > /dev/null 2>&1"
  ];

  # Please remove the hardcoded password from the configuration and set
  # the password using the "passwd" command after the first boot.

  users.users.root = {
    isNormalUser = false;
  };

  users.users.jkaye = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCBbeGO0Yz7TpzsLoSQyPxCl24kwn1qeI3Ncqj9mBn2Ody1tIICxhxP2xIcqRxhkM2wZEvzC79omsfsFsaEYqFoDwUlj6ylstiXm3y6PcLwZhZWIIveWE5PKJNAQBZGU/nZg2eRIaebx3kGR+jwheg+KKIXJLd1646T2bfJ+I4ux4oM4IWti0yJs2vpwjmcepv4IRk46vR8h9z1567HgpTn7T+GNDaSz29Un4lt5Rhsk3d92s5BLPf+T7+2NSuTonZdpgjyNiwrhhjR/XLDZE660vi8Vm+lKEdTl2pE+ShREmV7RB8fFGAfpHKnbgZSiVm6rR8KUQwIQc/Mj0GGTCxXl3WaPk0OXJHShTmTkw9eOX1aw5pkELmy2y4YJ0K9keNtgpIyQav6S7jLSQrv5+T+pyC1zko/P/9fuoiZbd96wbiZsBvxQ5u6WxJzsrWgtzjSw+FcwzIM202B0wkay6yja2oiiTlgXtfbZDOxjyZmUFNeZ1t6hDdLOa6EJk/jx3U= jordankaye2@penguin"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC6yLhQ//CuXo9t8HiF4oyD24u/Vh0IAhOJnZEX/375s9VRlh4I/tt9+ftYHM2lEmIwCGsmgZIoTL7xpAkYiyZ8l5jImpggQjvavImNNl/w7OHyvCOCYuQsyPtEkdgMg/7z0+JaeoxK9eTMs4WIm0eJxOzQpasr1zA1ag6vighf5UKX4mR59xaxgyTlSG+k08EkV0Fzjxksyjr1k2v48JCY0AtIHTrngkzpz+DQssCZAyjnGfSSqWF4puyAxs2EkDZauSy0TMMxJ9NwrrgwiAptvcvTacgwSNP8Kyp1amN0X+AhA4EgIKqcrDb9Yu+mDPD0gdMFodhzMWCulXlJJeXYZTDs93s1jseU+k+gvb84ms1MZuoqyNh1bFjPQkXhfgUURm7r6NJZi2WEgoryCZKUzjsY+1C6jWdvjmv9EZStlSFQXyuPb8QYOKAIG1JZvkZ9wt/vVUWdXwpe8/GhRn1O5dJvv8mKb1Ld/EL+7Or57QXyEtcfL6NWHePNq6oDnfM= jkaye@colwksdev001"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDdmVTIFpeY8sXxJupx5egTsb7jnkxkaz7li68RHjF03tDb/9WwpgrIFNcAXR114AlOqIz71s6egkrSG7mPRyVt1cNTjEouwCQDXKE0SZJRibhIxlgL2htRfPIj9xrUjehm8US8csioI2x7ymMi+u0qYv4jxW06eVvemHOvB4MN7RhxAnqNiXik/ng2JglgW3znG7KEbmFvARJqsXFCE7W/G/gS/veOkEumjnyHioz+x8SFe0Nm8cjHH0GBH1ueGP5uhtiGqI84/khMDFAga7iEC7FmWRQlb79F1Oc0lit6Iw+TPWt5s9KLE07wP2AsBG3lRx7PIdzuqHYFaU6qsLYRATtYRv8IPjeU60yBIR6NMLB4EWYVoD/PEAT/LJtaNKvvsXs0lt6WUr5BKQGPz4n1GTZlHMh5gYeHCnd0hzu/zai7rNSC5wHSRgsOPHjQm3wC0LkJ2WiMnRBO4djbWOtUhGOssVqi4H7fAd1ves2rJdVj0tbUfg5ucVcZX/U7b+0= jkaye@jkaye-framework"
    ];
  };
}
