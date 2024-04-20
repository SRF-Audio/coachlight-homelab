- name: Prepare Debian Docker host VM on Proxmox node
  hosts: localhost
  gather_facts: no
  vars:
    proxmox_api_token_id: "{{ lookup('env', 'PROXMOX_API_TOKEN_ID') }}"
    proxmox_api_token_secret: "{{ lookup('env', 'PROXMOX_API_TOKEN_SECRET') }}"
    proxmox_host: "{{ lookup('env', 'PROXMOX_HOST') }}"
    mac_address: "{{ op://HomeLab/coachlight-homelab SSH key/docker host vm/mac address }}"
    vm_ip: "{{ op://<vault>/<entry>/vm_ip }}"
    user: coachlight-homelab
  tasks:
    - name: Create Debian VM
      community.general.proxmox_kvm:
        api_user: root@pam
        api_token_id: "{{ proxmox_api_token_id }}"
        api_token_secret: "{{ proxmox_api_token_secret }}"
        api_host: "{{ proxmox_host }}"
        validate_certs: no
        node: macmini2
        vmid: 201
        name: debian-docker-host
        cpu: cores=2
        memory: 6144
        disk: 100
        storage: local-lvm
        net: '{"net0":"virtio,bridge=vmbr0,macaddr={{ mac_address }}}'
        iso: 'local:iso/debian-12.5.0-amd64-netinst.iso'
        ostype: l26
        bootdisk: virtio0
        boot: order=virtio0;ide2;net0
        args: "auto=true priority=critical url=http://yourserver/preseed.cfg"  # Example preseed URL

    - name: Configure VM post-installation
      hosts: "{{ vm_ip }}"
      become: yes
      tasks:
        - name: Wait for SSH to come up
          wait_for:
            port: 22
            host: '{{ inventory_hostname }}'
            timeout: 300
            delay: 10

        - name: Update all packages
          apt:
            update_cache: yes
            upgrade: 'dist'

        - name: Remove conflicting Docker packages
          apt:
            name: "{{ item }}"
            state: absent
          loop:
            - docker.io
            - docker-doc
            - docker-compose
            - podman-docker
            - containerd
            - runc
          ignore_errors: yes

        - name: Install useful packages
          apt:
            name: ['ca-certificates', 'curl', 'jq', 'nmap', 'vim', 'wget', 'zip', 'unzip', 'git', 'htop', 'net-tools']
            state: present
            update_cache: yes

        - name: Create Docker apt keyring directory
          file:
            path: /etc/apt/keyrings
            state: directory
            mode: '0755'

        - name: Add Docker's official GPG key
          get_url:
            url: https://download.docker.com/linux/debian/gpg
            dest: /etc/apt/keyrings/docker.asc
            mode: 'a+r'

        - name: Add Docker repository
          apt_repository:
            repo: "deb [arch={{ ansible_architecture }} signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian {{ ansible_distribution_release }} stable"
            state: present
            filename: docker

        - name: Update apt cache after adding Docker repository
          apt:
            update_cache: yes

        - name: Install Docker packages
          apt:
            name: "{{ item }}"
            state: present
          loop:
            - docker-ce
            - docker-ce-cli
            - containerd.io
            - docker-buildx-plugin
            - docker-compose-plugin

        - name: Test Docker installation
          command: docker run hello-world
          ignore_errors: yes

        - name: Ensure user exists
          user:
            name: "{{ user }}"
            shell: "/bin/bash"
            state: present

        - name: Add user to the Docker group
          user:
            name: "{{ user }}"
            group: docker
            append: yes

        - name: Ensure Docker service is running and enabled
          service:
            name: docker
            state: started
            enabled: yes

- name: Setup GitHub SSH Key for User
  hosts: "{{ vm_ip }}"
  become: yes
  become_user: "{{ user }}"
  tasks:
    - name: Ensure SSH directory exists
      file:
        path: "/home/{{ user }}/.ssh"
        state: directory
        mode: 0700
        owner: "{{ user }}"
        group: "{{ user }}"

    - name: Add public key to authorized_keys
      lineinfile:
        path: "/home/{{ user }}/.ssh/authorized_keys"
        line: "{{ public_key }}"
        create: yes
        mode: 0600
        owner: "{{ user }}"
        group: "{{ user }}"

    - name: Retrieve GitHub SSH private key from 1Password and write to file
      shell: op read "op://HomeLab/GitHub SSH Key/private key"
      register: github_ssh_key
      delegate_to: localhost

    - name: Write SSH key to file
      copy:
        dest: "/home/{{ user }}/.ssh/github-key"
        content: "{{ github_ssh_key.stdout }}"
        mode: 0600
        owner: "{{ user }}"
        group: "{{ user }}"
      when: github_ssh_key.stdout != ""

    - name: Test Docker without sudo
      command: docker ps
      failed_when: "'permission denied' in docker_test.stderr"

    - name: Clone GitHub repository using custom SSH key
      git:
        repo: "git@github.com:SRF-Audio/coachlight-homelab.git"
        dest: "/home/{{ user }}/coachlight-homelab"
        key_file: "/home/{{ user }}/.ssh/github-key"
        version: main

    - name: Run Docker Compose
      command: docker compose up -d
      args:
        chdir: "/home/{{ user }}/coachlight-homelab"