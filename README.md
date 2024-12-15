## Abstract

**Beyond Rational Artificial Intelligence Network (BRAIN)**

In pursuit of sustainable efficiency and seamless integration of technology and humanity. It promotes AI - SUPPORTED evolutionary efficiency.

Without meaning, there is no purpose, and without purpose, nonsense arises, a non-polynomial amount of them.

## Description

In a world full of cutting-edge technologies and breaking-news, BRAIN emerges as an innovative initiative designed to bridge STEAM (education) with "steam" (technology and games) using cutting-edge tools and methodologies. Its goal is to foster a sustainable balance between human creativity and technological progress, addressing real-world challenges through:

It also develops the idea of Tim Berners Lee, SOLID, the idea to create a Planetary File System, my idea is to combine existing technologies to create efficiency from his original ideas. That way, we integrate the cloud services with our own devices in a proper and efficient way.

It uses the following ideas:

- **LND**: Connection to local payment systems. (*money*) (TODO: discuss it deeply)
- **BTC**: Integration with major nodes in the global payment system. (*gold*)
- **LLM**: Language Models for contextual understanding (*personal trainers*)
- **SQL**: Structured data management (*information*)
- **RDF**: Semantic connections and relationships (*knowledge*)
- **ADN**: A metaphor for human evolution and interconnection (*people*)

## Folder structure

- **`docker-compose:`** 
  - **`- lnd`**: Local networks on the Global Payment Network. [TODO]
  - **`- matrix`**: Human network. Use signal to connect devices 
  - **`- nextcloud`**: Profile and desktop. Use file sync to connect devices.
  - **`- wordpress`**: Shared experiences. 
  - **`- nextjs`**: A UI with 3 tabs:
    - Monitoring: Display all server stats. (system info) [DONE]
    - Payment: Manage LND connections. (payment network, Paythering) [TODO]
    - Training: Train with your own LLM trainer. (timeless personal trainer) [DONE]
- **`volumes/`**: System data stored in an external Docker registry.  
- **`Makefile`**: System controls (start, reload, backup, restore)
- **`default`**: system configuration sync with nginx in the host
- **`.env`**: Default system values (password, user, etc)

## Usage

`make start`: start the individual or organization BRAIN

`make stop`: shutdown the system containers of BRAIN

`make save`: save the current BRAIN snapsoot as a docker tag

`make load`: restore BRAIN system from a docker tag

By installing tools such as **Nextcloud** and **Signal** on your devices, you can keep files synchronized for personal or institutional use and communicate within different networks, school and family for example.  

### Civil Institutions

For institutional usage, we highly recommend enabling lightweight payments through Lightning Network, allowing fast and affordable transactions using older devices, such as smartphones. This simplifies integration and promotes financial inclusion without the need for expensive machines.  

## Get Involved

We believe in collaboration and shared purpose. Whether you're a programmer, educator, or philosopher, there's a place for you in BRAIN.  

### How to Contribute

1. Explore the repository and familiarize yourself with its structure.  
2. Join discussions on community-driven platforms.  
3. Share ideas to continue building bridges between humanity and technology.  

## Note

Locally, we always see a circle—closed, comprehensible, and complete.

## Open issues [TODO]:

- Discuss about using Signal and Bridges to matrix or try out Element.
- Discuss if lnd is good enough or we need other implementations.
- Discuss how we can get meaning from the Paythering example (see [INFO.md](https://github.com/JorgeMartinezPizarro/brain/blob/main/INFO.md))
- Try out the core lighting implementation.
Created by [ideniox](https://ideniox.com) and licensed as a [HaaT](https://github.com/JorgeMartinezPizarro/haat)

